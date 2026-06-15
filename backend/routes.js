const express = require('express');
const router = express.Router();

// DEFINE CONTROLLER (IMPORT CONTRONLLER)
const { register, login, updateImageProfile, getUsers } = require('./controllers/userController');
const { getAllCategories, creteateNewCategory, detailCategoryById , updateCategoryById, deleteCategoryById} = require('./controllers/categoryController');
const { getAllProducts, getProductById, createProduct, updateProduct, deleteProduct } = require('./controllers/productController');

const upload = require('./middleware/upload');


// FORMAT DEFINE ROUTER
// router.[http-req]([url-endpoint], [method])
// ex : router.post('/register', register);

// ROUTE UNTUK AUTHENTICATION
router.get('/users', getUsers);
router.post('/register', register);
router.post('/login', login);

// ROUTE HANDLING IMAGE PROFILE
router.patch('/update-image/:id', upload.single('image'), updateImageProfile)

// ROUTE UNTUK HANDLE DATA  CATEGORY
router.get('/categories', getAllCategories);
router.post('/categories', creteateNewCategory);
router.get('/categories/:id', detailCategoryById);
router.patch('/categories/:id', updateCategoryById);
router.delete('/categories/:id', deleteCategoryById);


// ROUTE UNTUK HANDLE DATA PRODUCT
router.get('/products/:userid', getAllProducts);
router.get('/products/detail/:id', getProductById);
router.post('/products/:userid', createProduct);
router.patch('/products/:id', updateProduct);
router.delete('/products/:id', deleteProduct);


// router.post('/upload', upload.single('image'), (req, res) => {
//   res.status(201).json({ imageUrl: `/uploads/${req.file.filename}` });
// });

module.exports = router;
