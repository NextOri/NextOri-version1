import axios from "axios";
import { API_ROUTES_URL } from "../config/api";

const api = axios.create({

    baseURL: API_ROUTES_URL,

    headers: {
        "Content-Type": "application/json"
    }

});

export default api;
