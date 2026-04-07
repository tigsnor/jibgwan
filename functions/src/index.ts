import * as admin from "firebase-admin";
import {
  signup,
  login,
  approveUser,
  getUserRole,
  rejectUser,
  logout,
} from "./auth";

admin.initializeApp();

export {
  signup,
  login,
  approveUser,
  getUserRole,
  rejectUser,
  logout,
};
