import { Pool } from 'pg';
import { readFileSync } from 'fs';
import { join } from 'path';
import { logger } from '../utils/logger';

export class MigrationRunner {
  private pool: Pool;

  constructor(pool: Pool) {
    this.pool = pool;
  }

  async runMigrations(): Promise<void> {
    try {
      logger.info('Starting database migrations...');

      // Create migrations table if it doesn't exist
      await this.createMigrationsTable();

      // Get list of migration files
      const migrationFiles = this.getMigrationFiles();

      // Run each migration
      for (const file of migrationFiles) {
        await this.runMigration(file);
      }

      logger.info('Database migrations completed successfully');
    } catch (error) {
      logger.error('Migration failed:', error);
      throw error;
    }
  }

  private async createMigrationsTable(): Promise<void> {
    const query = `
      CREATE TABLE IF NOT EXISTS migrations (
        id SERIAL PRIMARY KEY,
        filename VARCHAR(255) UNIQUE NOT NULL,
        executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `;

    await this.pool.query(query);
  }

  private getMigrationFiles(): string[] {
    // In a real application, you would read from the filesystem
    // For now, we'll return the known migration files
    return [
      '001_initial_schema.sql'
    ];
  }

  private async runMigration(filename: string): Promise<void> {
    try {
      // Check if migration has already been run
      const checkQuery = 'SELECT id FROM migrations WHERE filename = $1';
      const result = await this.pool.query(checkQuery, [filename]);

      if (result.rows.length > 0) {
        logger.info(`Migration ${filename} already executed, skipping...`);
        return;
      }

      // Read migration file
      const migrationPath = join(__dirname, filename);
      const migrationSQL = readFileSync(migrationPath, 'utf8');

      // Execute migration
      await this.pool.query(migrationSQL);

      // Record migration as executed
      const insertQuery = 'INSERT INTO migrations (filename) VALUES ($1)';
      await this.pool.query(insertQuery, [filename]);

      logger.info(`Migration ${filename} executed successfully`);
    } catch (error) {
      logger.error(`Failed to execute migration ${filename}:`, error);
      throw error;
    }
  }

  async rollbackMigration(filename: string): Promise<void> {
    try {
      // Check if migration exists
      const checkQuery = 'SELECT id FROM migrations WHERE filename = $1';
      const result = await this.pool.query(checkQuery, [filename]);

      if (result.rows.length === 0) {
        throw new Error(`Migration ${filename} not found`);
      }

      // Remove migration record
      const deleteQuery = 'DELETE FROM migrations WHERE filename = $1';
      await this.pool.query(deleteQuery, [filename]);

      logger.info(`Migration ${filename} rolled back successfully`);
    } catch (error) {
      logger.error(`Failed to rollback migration ${filename}:`, error);
      throw error;
    }
  }

  async getMigrationStatus(): Promise<Array<{ filename: string; executed_at: string }>> {
    const query = 'SELECT filename, executed_at FROM migrations ORDER BY executed_at';
    const result = await this.pool.query(query);
    return result.rows;
  }
}
