const { Product, Category } = require("../models");

const getAllProducts = async (req, res) => {
  try {
    const { userid } = req.params;
    const products = await Product.findAll({
      where: { createdBy: userid },
      include: { model: Category },
    });

    products.length > 0
      ? res.status(200).json({ message: "succes", data: products })
      : res.json({ message: "No products found" });
  } catch (error) {
    console.log(error);
  }
};

const getProductById = async (req, res) => {
  try {
    const { id } = req.params;

    const product = await Product.findOne({
      where: { id: id},
      include: { model: Category},
    });

    return res.json({
      message: "success",
      data : product
    })
  } catch (error) {
    console.log(error);
  }
};

const createProduct = async (req, res) => {
  try {
    // "name": "Polo Shirt",
    // "qty": 25,
    // "categoryId": 3,
    // "url": null,
    // "createdBy": 2,
    // "updatedBy": 2,
    // "createdAt": "2024-06-17T12:42:02.000Z",
    // "updatedAt":
    const { userid } = req.params;
    const { name, qty, categoryId, url } = req.body;

    const productSameOnSameUserId = await Product.findOne({
      where: { name: name, createdBy: userid },
    });

    if (productSameOnSameUserId) {
      return res.json({
        message: "Product already exists",
      })
    }

    const createNewProduct = await Product.create({ name, qty, categoryId, url, createdBy: userid });
    return res.status(201).json({
      message: "success",
      data : createNewProduct
    })
  } catch (error) {
    console.log(error)
  }
};

const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, qty, categoryId, url } = req.body;
    const updateProduct =  await Product.update({ name, qty, categoryId, url }, { where: { id } });
    return res.status(200).json({
      message: "success",
      data : updateProduct
    })
  } catch (error) {
    // res.status(400).json({ error: error.message });
    console.log(error)
  }
};

const deleteProduct = async (req, res) => {
  try {
    const product = await Product.findByPk(req.params.id);
    if (product) {
      await product.destroy();
      res.status(200).json({
        message: "Product deleted successfully",
      });
    } else {
      res.status(404).json({ message: "Product not found" });
    }
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

module.exports = {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
};
