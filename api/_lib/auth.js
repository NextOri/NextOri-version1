import jwt from "jsonwebtoken";
import { parse, serialize } from "cookie";

const JWT_SECRET = process.env.JWT_SECRET || "nextori_super_secret_jwt_key_2026";
const COOKIE_NAME = "nextori_session";

export function signToken(payload) {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: "7d" });
}

export function verifyToken(token) {
  try {
    return jwt.verify(token, JWT_SECRET);
  } catch {
    return null;
  }
}

export function getUserFromRequest(req) {
  // 1. Check Cookie
  if (req.headers && req.headers.cookie) {
    const cookies = parse(req.headers.cookie);
    if (cookies[COOKIE_NAME]) {
      const decoded = verifyToken(cookies[COOKIE_NAME]);
      if (decoded && decoded.id_user) {
        return decoded;
      }
    }
  }

  // 2. Check Authorization Header
  if (req.headers && req.headers.authorization) {
    const parts = req.headers.authorization.split(" ");
    if (parts.length === 2 && parts[0] === "Bearer") {
      const decoded = verifyToken(parts[1]);
      if (decoded && decoded.id_user) {
        return decoded;
      }
    }
  }

  // 3. Fallback to id_user in query or body if provided
  if (req.query && req.query.id_user) {
    const id = parseInt(req.query.id_user, 10);
    if (!isNaN(id)) return { id_user: id };
  }
  if (req.body && req.body.id_user) {
    const id = parseInt(req.body.id_user, 10);
    if (!isNaN(id)) return { id_user: id };
  }

  return null;
}

export function setAuthCookie(res, token) {
  const cookieHeader = serialize(COOKIE_NAME, token, {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: 60 * 60 * 24 * 7, // 7 days
    path: "/",
  });
  res.setHeader("Set-Cookie", cookieHeader);
}

export function clearAuthCookie(res) {
  const cookieHeader = serialize(COOKIE_NAME, "", {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    maxAge: 0,
    path: "/",
  });
  res.setHeader("Set-Cookie", cookieHeader);
}
