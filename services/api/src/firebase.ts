import {
  applicationDefault,
  getApp,
  getApps,
  initializeApp,
} from "firebase-admin/app";
import { getAppCheck } from "firebase-admin/app-check";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

import { config } from "./config.js";

const app =
  getApps().length > 0
    ? getApp()
    : initializeApp({
        credential: applicationDefault(),
        projectId: config.GCP_PROJECT_ID,
      });

export const auth = getAuth(app);
export const appCheck = getAppCheck(app);
export const db = getFirestore(app);
export const messaging = getMessaging(app);

db.settings({ ignoreUndefinedProperties: true });
