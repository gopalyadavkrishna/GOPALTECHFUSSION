import { db, messaging } from "../firebase.js";

export async function notifyArea(
  areaId: string,
  input: {
    title: string;
    body: string;
    data: Record<string, string>;
  },
): Promise<void> {
  await messaging.send({
    topic: `area_${areaId}`,
    notification: {
      title: input.title,
      body: input.body,
    },
    data: input.data,
    android: {
      priority: "high",
      notification: {
        channelId: "outage_updates",
        sound: "default",
      },
    },
  });
}

export async function notifyUser(
  userId: string,
  input: {
    title: string;
    body: string;
    data: Record<string, string>;
  },
): Promise<void> {
  const devices = await db
    .collection("users")
    .doc(userId)
    .collection("devices")
    .where("enabled", "==", true)
    .limit(500)
    .get();
  const tokens = devices.docs
    .map((document) => document.data().fcmToken)
    .filter((token): token is string => typeof token === "string");
  if (tokens.length === 0) return;
  await messaging.sendEachForMulticast({
    tokens,
    notification: {
      title: input.title,
      body: input.body,
    },
    data: input.data,
    android: {
      priority: "high",
      notification: {
        channelId: "complaint_updates",
        sound: "default",
      },
    },
  });
}
