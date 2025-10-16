import { Router } from 'express';
import authRoutes from './auth';
import userRoutes from './users';
import cryptoRoutes from './crypto';
import analysisRoutes from './analysis';
import notificationRoutes from './notifications';
import adminRoutes from './admin';
import healthRoutes from './health';

const router = Router();

// Health check route
router.use('/health', healthRoutes);

// API routes
router.use('/auth', authRoutes);
router.use('/users', userRoutes);

// API v1 routes (for mobile app compatibility)
router.use('/v1/auth', authRoutes);
router.use('/v1/users', userRoutes);
router.use('/v1/crypto', cryptoRoutes);
router.use('/v1/analysis', analysisRoutes);
router.use('/v1/notifications', notificationRoutes);
router.use('/v1/admin', adminRoutes);

// Original API routes (backward compatibility)
router.use('/crypto', cryptoRoutes);
router.use('/analysis', analysisRoutes);
router.use('/notifications', notificationRoutes);
router.use('/admin', adminRoutes);

// 404 handler for undefined routes
router.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Route not found',
    path: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString()
  });
});

export { router as routes };
export default router;
