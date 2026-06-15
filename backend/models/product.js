'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Product extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      Product.belongsTo(models.Category, { 
        foreignKey: 'categoryId', 
        onDelete: 'CASCADE', 
        onUpdate: 'CASCADE' 
      });

      Product.belongsTo(models.User, { 
        foreignKey: 'createdBy', 
        onDelete: 'CASCADE', 
        onUpdate: 'CASCADE' 
      });

      Product.belongsTo(models.User, { 
        foreignKey: 'updatedBy', 
        onDelete: 'CASCADE', 
        onUpdate: 'CASCADE' 
      });
    }
  }
  Product.init({
    name: DataTypes.STRING,
    qty: DataTypes.INTEGER,
    categoryId: DataTypes.INTEGER,
    url: DataTypes.STRING,
    createdBy: DataTypes.STRING,
    updatedBy: DataTypes.STRING
  }, {
    sequelize,
    modelName: 'Product',
  });
  return Product;
};