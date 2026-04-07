import * as admin from "firebase-admin";
import { signup, login, approveUser } from "./auth";

admin.initializeApp();

export {
  signup,
  login,
  approveUser,
};
