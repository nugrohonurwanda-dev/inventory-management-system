"use strict";

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    // 1. Matikan pengecekan foreign key sementara
    await queryInterface.sequelize.query('SET FOREIGN_KEY_CHECKS = 0;');

    await queryInterface.bulkInsert("Products", [
      {
        name: "Asus ROG Strix",
        qty: 10,
        categoryId: 6,
        url: null,
        createdBy: 1,
        updatedBy: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: "Realme GT",
        qty: 100,
        categoryId: 1,
        url: null,
        createdBy: 1,
        updatedBy: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
      {
        name: "Polo Shirt",
        qty: 25,
        categoryId: 3,
        url: null,
        createdBy: 2,
        updatedBy: 2,
        createdAt: new Date(),
        updatedAt: new Date(),
      },
    ]);

    // 2. Hidupkan kembali pengecekan foreign key
    await queryInterface.sequelize.query('SET FOREIGN_KEY_CHECKS = 1;');
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.bulkDelete("Products", null, {});
  },
};