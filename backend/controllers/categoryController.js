const { Category } = require('../models');

const getAllCategories = async (req, res) => {
  try {
    const categories = await Category.findAll();
    return res.status(200).json({
      message : 'Success',
      data : categories}
    );
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

const creteateNewCategory = async (req, res) => {
  try {
    const { name } = req.body;

    // category sudah ada
    const findSameCategory = await Category.findOne({ where: { name } });
    if(findSameCategory) {
      return res.json({ error: `Category ${name} already exists` });
    }

    // create new category
    const newCategory = await Category.create({ name });
    return res.status(201).json({
      message : 'Success',
      data : newCategory
    })
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
}

const detailCategoryById = async (req, res) => {
  try {
    // tangkap data id yang dikirim dari url
    const { id } = req.params;

    const category = await Category.findByPk(id);

    if (!category) {
      return res.json({
        message : 'Category not found'
      })
    }

    return res.status(200).json({
      message : 'Success',
      data : category
    })
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
}

const updateCategoryById = async (req, res) => {
  try {
    const { id } = req.params;
    const { name } = req.body;

    // category sudah ada
    const findSameCategory = await Category.findOne({ where: { name } });
    if(findSameCategory) {
      return res.json({ error: `Category ${name} already exists` });
    }

    // update category
    const updateCategory = await Category.update({ name }, { where: { id } });
    return res.status(200).json({
      message : 'Success',
      data : updateCategory
    })
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
}

const deleteCategoryById = async (req, res) => {
  try {
    const {id} = req.params;

    const findCategoryById = await Category.findByPk(id);
    if (!findCategoryById) {
      return res.json({
        message : 'Category not found'
      })
    }

    const deleteCategory = await Category.destroy({ where: { id } });
    return res.status(200).json({
      message : 'Success',
      data : deleteCategory
    })
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

module.exports = { getAllCategories, creteateNewCategory, detailCategoryById, updateCategoryById, deleteCategoryById };
