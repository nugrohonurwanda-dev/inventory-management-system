'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {

    // membuat data dumy untuk user
    await queryInterface.bulkInsert('Users', [
      {
        username: 'user',
        password: 'password',
        image: null,
        createdAt: new Date(),
        updatedAt: new Date()
      },
      {
        username: 'user2',
        password: 'password2',
        image: null,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    ]);
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.bulkDelete('Users', null, {});
  }
};
