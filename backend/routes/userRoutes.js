const express = require('express');
const UserController = require('../controllers/UserController');
const router = express.Router();

// User routes
router.get("/", UserController.getAllUsers);
router.get("/profile", UserController.getProfile);
router.get("/search", UserController.searchUsers);
router.get("/:id", UserController.getUserById);
router.put("/:id", UserController.updateUser);
router.delete("/:id", UserController.deleteUser);
router.put("/:id/password", UserController.updatePassword);

module.exports = router;