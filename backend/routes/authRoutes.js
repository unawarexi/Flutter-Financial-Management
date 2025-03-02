const express = require('express');
const AuthController = require('../controllers/AuthController');
const router = express.Router();

// Authentication routes
router.post("/register", AuthController.register);
router.post("/login", AuthController.login);
router.post("/refresh-token", AuthController.refreshToken);
router.post("/logout", AuthController.logout);
router.get("/verify-email/:token", AuthController.verifyEmail);
router.post("/request-password-reset", AuthController.requestPasswordReset);
router.post("/reset-password", AuthController.resetPassword);

module.exports = router;