'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.bulkInsert('Categories', [
      {
        name: 'Phone', 
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Komputer', 
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Buku', 
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        name: 'Laptop', 
        createdAt: new Date(),
        updatedAt: new Date()
      },
    ]);
  },

  async down (queryInterface, Sequelize) {
      await queryInterface.bulkDelete('Categories', null, {});
  }
};
