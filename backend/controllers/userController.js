const path = require("path");
const fs = require("fs");

// controllers/userController.js
const { User } = require("../models");

const getUsers = async (req, res) => {
  try {
    const response = await User.findAll();
    return res.status(200).json({
      message: "Success",
      data: response,
    });
  } catch (error) {
    console.log(error);
  }
};

const register = async (req, res) => {
  try {
    // tangkap reques body
    const { username, password } = req.body;

    // debug
    // console.table({ username, password });

    // validasi user sudah ada
    const user = await User.findOne({ where: { username } });
    if (user) {
      return res.json({ message: "Username already exists" });
    }

    // create user
    const createUserResponse = await User.create({ username, password });

    //  return response
    return res.status(201).json({
      message: "User created successfully",
      data: createUserResponse,
    });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

const login = async (req, res) => {
  try {
    // tangkap reques body
    const { username, password } = req.body;

    // debug
    // console.table({ username, password });

    // cek data user ditemukan atau tidak berdasarkan username
    const foundDataUser = await User.findOne({ where: { username } });
    if (!foundDataUser) {
      return res.json({ message: `${username} not found` });
    }

    // console.table(foundDataUser.password);
    // password cek
    if (password !== foundDataUser.password) {
      return res.json({ message: "Wrong password" });
    }

    // respone ketika data user dinyatakan valid
    return res.status(200).json({
      message: "Login success",
      data: foundDataUser,
    });
  } catch (error) {
    return res.status(400).json({ error: error.message });
  }
};

const updateImageProfile = async (req, res) => {
  try {
    const { id } = req.params;
    const image = req.file;
    const imagePath = image ? image.filename : null;

    // console.log(image)

    // PENCARIAN DATA USER
    // ---------------------------------------------------------
    const user_exist = await User.findOne({
      where: { id },
    });

    // DATA USER TIDAK DITEMUKAN
    // ---------------------------------------------------------
    if (!user_exist) {
      return res.json({
        message: `the user with ID ${id} not found`,
      });
    }

    // CEK PATH IMAGE LAMA ADA ATAU TIDAK
    // ---------------------------------------------------------
    const image_path_old = user_exist.image;

    if (image_path_old === null) {
      const response = await User.update(
        {
          image: imagePath,
        },
        {
          where: { id },
        }
      );

      return res.status(200).json({
        message: "Success",
        data: response,
      });
    }

    if (image_path_old !== null) {
      const image_path = path.join(
        __dirname,
        `../public/images/${image_path_old}`
      );
      fs.unlinkSync(image_path);

      const response = await User.update(
        {
          image: imagePath,
        },
        {
          where: { id },
        }
      );

      return res.status(200).json({
        message: "Success",
        data: response,
      });
    }

    return res.json({ message: "success", data: image });
  } catch (error) {
    console.log(error);
  }
};

module.exports = { register, login, updateImageProfile, getUsers };
