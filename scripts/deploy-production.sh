#!/bin/bash

# ========================================
# BTC Baran Production Deployment Script
# Host: btc.nazlihw.com
# ========================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

# Configuration
PROJECT_NAME="btcbaran"
PROJECT_DIR="/opt/btcbaran"
BACKUP_DIR="/opt/btcbaran/backups"
LOG_DIR="/opt/btcbaran/logs"
SSL_DIR="/etc/letsencrypt/live/btc.nazlihw.com"
DOCKER_COMPOSE_FILE="docker-compose.production.yml"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "This script should not be run as root"
fi

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    error "Project directory $PROJECT_DIR does not exist"
fi

# Create necessary directories
log "Creating necessary directories..."
mkdir -p "$BACKUP_DIR" "$LOG_DIR" "$PROJECT_DIR/ssl" "$PROJECT_DIR/webroot"

# Function to check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed"
    fi
    
    # Check if user is in docker group
    if ! groups $USER | grep -q docker; then
        error "User $USER is not in docker group"
    fi
    
    log "Prerequisites check passed"
}

# Function to backup current deployment
backup_current_deployment() {
    log "Creating backup of current deployment..."
    
    BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
    BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"
    
    mkdir -p "$BACKUP_PATH"
    
    # Backup Docker volumes
    if docker volume ls | grep -q "${PROJECT_NAME}_postgres_data"; then
        log "Backing up PostgreSQL data..."
        docker run --rm -v "${PROJECT_NAME}_postgres_data:/data" -v "$BACKUP_PATH:/backup" \
            alpine tar czf /backup/postgres_data.tar.gz -C /data .
    fi
    
    if docker volume ls | grep -q "${PROJECT_NAME}_redis_data"; then
        log "Backing up Redis data..."
        docker run --rm -v "${PROJECT_NAME}_redis_data:/data" -v "$BACKUP_PATH:/backup" \
            alpine tar czf /backup/redis_data.tar.gz -C /data .
    fi
    
    # Backup configuration files
    cp -r "$PROJECT_DIR"/docker "$PROJECT_DIR"/nginx "$PROJECT_DIR"/monitoring "$BACKUP_PATH"/ 2>/dev/null || true
    
    log "Backup created at $BACKUP_PATH"
}

# Function to stop current services
stop_services() {
    log "Stopping current services..."
    
    cd "$PROJECT_DIR"
    
    if [ -f "$DOCKER_COMPOSE_FILE" ]; then
        docker-compose -f "$DOCKER_COMPOSE_FILE" down --remove-orphans
    fi
    
    # Stop any running containers with project name
    docker ps -q --filter "name=${PROJECT_NAME}_" | xargs -r docker stop
    
    log "Services stopped"
}

# Function to update SSL certificates
update_ssl_certificates() {
    log "Updating SSL certificates..."
    
    # Check if Let's Encrypt certificates exist
    if [ ! -d "$SSL_DIR" ]; then
        warn "SSL certificates not found. Please run certbot first:"
        warn "sudo certbot certonly --standalone -d btc.nazlihw.com"
        return 1
    fi
    
    # Copy certificates to project directory
    sudo cp -r "$SSL_DIR" "$PROJECT_DIR/ssl/"
    sudo chown -R $USER:$USER "$PROJECT_DIR/ssl"
    
    log "SSL certificates updated"
}

# Function to deploy new version
deploy_new_version() {
    log "Deploying new version..."
    
    cd "$PROJECT_DIR"
    
    # Pull latest changes
    if [ -d ".git" ]; then
        log "Pulling latest changes from git..."
        git pull origin main
    fi
    
    # Build and start services
    log "Building and starting services..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" build --no-cache
    
    # Start services
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
    
    log "Deployment completed"
}

# Function to verify deployment
verify_deployment() {
    log "Verifying deployment..."
    
    # Wait for services to start
    sleep 30
    
    # Check if all containers are running
    RUNNING_CONTAINERS=$(docker ps --filter "name=${PROJECT_NAME}_" --format "{{.Names}}" | wc -l)
    EXPECTED_CONTAINERS=7  # nginx, postgres, redis, backend, prometheus, grafana, fail2ban
    
    if [ "$RUNNING_CONTAINERS" -eq "$EXPECTED_CONTAINERS" ]; then
        log "All services are running"
    else
        error "Expected $EXPECTED_CONTAINERS services, but $RUNNING_CONTAINERS are running"
    fi
    
    # Check service health
    log "Checking service health..."
    
    # Check Nginx
    if curl -f -s https://btc.nazlihw.com/api/health > /dev/null; then
        log "Nginx is healthy"
    else
        error "Nginx health check failed"
    fi
    
    # Check Backend API
    if curl -f -s http://localhost:3000/api/health > /dev/null; then
        log "Backend API is healthy"
    else
        error "Backend API health check failed"
    fi
    
    # Check Database
    if docker exec "${PROJECT_NAME}_postgres" pg_isready -U btcbaran_user > /dev/null; then
        log "PostgreSQL is healthy"
    else
        error "PostgreSQL health check failed"
    fi
    
    # Check Redis
    if docker exec "${PROJECT_NAME}_redis" redis-cli ping | grep -q "PONG"; then
        log "Redis is healthy"
    else
        error "Redis health check failed"
    fi
    
    log "Deployment verification completed successfully"
}

# Function to setup monitoring
setup_monitoring() {
    log "Setting up monitoring..."
    
    # Create monitoring directories
    mkdir -p "$PROJECT_DIR/monitoring/prometheus" "$PROJECT_DIR/monitoring/grafana" "$PROJECT_DIR/monitoring/fail2ban"
    
    # Copy monitoring configurations
    if [ -f "monitoring/prometheus/prometheus.yml" ]; then
        cp monitoring/prometheus/prometheus.yml "$PROJECT_DIR/monitoring/prometheus/"
    fi
    
    if [ -d "monitoring/grafana" ]; then
        cp -r monitoring/grafana/* "$PROJECT_DIR/monitoring/grafana/"
    fi
    
    if [ -d "monitoring/fail2ban" ]; then
        cp -r monitoring/fail2ban/* "$PROJECT_DIR/monitoring/fail2ban/"
    fi
    
    log "Monitoring setup completed"
}

# Function to setup security
setup_security() {
    log "Setting up security configurations..."
    
    # Create security directories
    mkdir -p "$PROJECT_DIR/docker/postgres" "$PROJECT_DIR/docker/redis" "$PROJECT_DIR/nginx"
    
    # Copy security configurations
    if [ -f "docker/postgres/postgresql.conf" ]; then
        cp docker/postgres/postgresql.conf "$PROJECT_DIR/docker/postgres/"
    fi
    
    if [ -f "docker/postgres/pg_hba.conf" ]; then
        cp docker/postgres/pg_hba.conf "$PROJECT_DIR/docker/postgres/"
    fi
    
    if [ -f "docker/redis/redis.conf" ]; then
        cp docker/redis/redis.conf "$PROJECT_DIR/docker/redis/"
    fi
    
    if [ -f "nginx/nginx.conf" ]; then
        cp nginx/nginx.conf "$PROJECT_DIR/nginx/"
    fi
    
    if [ -f "nginx/sites-available/btc.nazlihw.com" ]; then
        cp nginx/sites-available/btc.nazlihw.com "$PROJECT_DIR/nginx/"
    fi
    
    log "Security setup completed"
}

# Function to cleanup old backups
cleanup_old_backups() {
    log "Cleaning up old backups..."
    
    # Keep only last 10 backups
    cd "$BACKUP_DIR"
    ls -t | tail -n +11 | xargs -r rm -rf
    
    log "Old backups cleaned up"
}

# Function to show deployment status
show_status() {
    log "Deployment Status:"
    echo "=================="
    
    cd "$PROJECT_DIR"
    
    # Show running containers
    echo "Running Containers:"
    docker ps --filter "name=${PROJECT_NAME}_" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    echo ""
    
    # Show service logs
    echo "Recent Logs:"
    docker-compose -f "$DOCKER_COMPOSE_FILE" logs --tail=10
    
    echo ""
    
    # Show resource usage
    echo "Resource Usage:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
}

# Main deployment function
main() {
    log "Starting BTC Baran production deployment..."
    log "Target host: btc.nazlihw.com"
    log "Project directory: $PROJECT_DIR"
    
    # Check prerequisites
    check_prerequisites
    
    # Create backup
    backup_current_deployment
    
    # Stop current services
    stop_services
    
    # Update SSL certificates
    update_ssl_certificates
    
    # Setup security and monitoring
    setup_security
    setup_monitoring
    
    # Deploy new version
    deploy_new_version
    
    # Verify deployment
    verify_deployment
    
    # Cleanup old backups
    cleanup_old_backups
    
    # Show final status
    show_status
    
    log "Production deployment completed successfully!"
    log "Application is available at: https://btc.nazlihw.com"
    log "Monitoring dashboard: http://localhost:3001 (Grafana)"
    log "Metrics endpoint: http://localhost:9090 (Prometheus)"
}

# Handle script arguments
case "${1:-}" in
    "status")
        show_status
        ;;
    "backup")
        backup_current_deployment
        ;;
    "verify")
        verify_deployment
        ;;
    "stop")
        stop_services
        ;;
    "start")
        deploy_new_version
        verify_deployment
        ;;
    "restart")
        stop_services
        deploy_new_version
        verify_deployment
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  (no args)  - Full deployment"
        echo "  status     - Show deployment status"
        echo "  backup     - Create backup only"
        echo "  verify     - Verify deployment only"
        echo "  stop       - Stop services only"
        echo "  start      - Start services only"
        echo "  restart    - Restart services only"
        echo "  help       - Show this help message"
        ;;
    *)
        main
        ;;
esac
