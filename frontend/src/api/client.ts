const API_BASE_URL = import.meta.env.VITE_API_BASE_URL ?? "http://127.0.0.1:8080/api";

type RequestOptions = RequestInit & {
  authToken?: string;
};

export type AdminMetric = {
  label: string;
  value: string;
  delta: string;
  tone: "teal" | "blue" | "amber" | "coral";
};

export type AdminRevenuePoint = {
  month: string;
  revenue: number;
};

export type AdminBooking = {
  id: string;
  tripTitle: string;
  location: string;
  date: string;
  guideName: string;
  travelers: number;
  totalFee: number;
  status: string;
  paymentStatus: string;
};

export type AdminTour = {
  id: string;
  title: string;
  location?: string;
  imageUrl: string;
  price: number;
  category: string;
  rating: number;
  reviewCount: number;
  bookingRate: number;
  description?: string;
  duration?: string;
  startDate?: string;
};

export type AdminTourPayload = {
  title: string;
  description?: string;
  imageUrl?: string;
  price: number;
  location?: string;
  duration?: string;
  startDate?: string;
  rating?: number;
  reviewCount?: number;
  category?: string;
};

export type AdminGuide = {
  id: string;
  name: string;
  location?: string;
  avatarUrl?: string;
  rating: number;
  activeTrips: number;
  responseRate: number;
};

export type AdminActivity = {
  title: string;
  meta: string;
  tone: "teal" | "blue" | "amber" | "coral";
};

export type AdminDashboard = {
  metrics: AdminMetric[];
  revenue: AdminRevenuePoint[];
  recentBookings: AdminBooking[];
  topTours: AdminTour[];
  topGuides: AdminGuide[];
  activities: AdminActivity[];
};

export type AdminEmailTemplate = {
  subject: string;
  logoText: string;
  title: string;
  body: string;
  buttonLabel: string;
  buttonUrl: string;
  footer: string;
};

export type AdminChatConversation = {
  userId: string;
  name: string;
  avatarUrl?: string;
  lastMessage: string;
  lastMessageTime?: string;
  unreadCount: number;
};

export type AdminChatMessage = {
  id: string;
  senderId?: string;
  senderName: string;
  mine: boolean;
  type: "text" | "image" | "audio";
  text: string;
  imageUrls: string[];
  audioUrl?: string;
  durationSeconds?: number;
  timestamp?: string;
};

export type AdminChat = {
  conversations: AdminChatConversation[];
  activeConversation?: AdminChatConversation;
  messages: AdminChatMessage[];
};

export type AdminChatSendPayload = {
  receiverId: string;
  type: "text" | "image" | "audio";
  text?: string;
  imageUrls?: string[];
  audioUrl?: string;
  durationSeconds?: number;
};

export type AdminInvoice = {
  billId: string;
  billName: string;
  date?: string;
  amount: number;
};

export type AdminPaymentInfo = {
  id?: string;
  cardHolderName: string;
  cardNumberMasked: string;
  provider: string;
  type: string;
};

export type AdminSubscription = {
  planName: string;
  yearlyPrice: number;
  startedAt?: string;
  validUntil?: string;
};

export type AdminPlan = {
  name: string;
  yearlyPrice: number;
  description: string;
  selected: boolean;
};

export type AdminBilling = {
  invoices: AdminInvoice[];
  paymentInfo: AdminPaymentInfo;
  subscription: AdminSubscription;
  plans: AdminPlan[];
};

export async function apiRequest<T>(path: string, options: RequestOptions = {}): Promise<T> {
  const headers = new Headers(options.headers);
  headers.set("Content-Type", "application/json");

  if (options.authToken) {
    headers.set("Authorization", `Bearer ${options.authToken}`);
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers
  });

  if (!response.ok) {
    throw new Error(`API request failed: ${response.status}`);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json() as Promise<T>;
}

export const adminApi = {
  login(email: string, password: string) {
    return apiRequest<{ token: string; email: string; role: string }>("/admin/auth/login", {
      method: "POST",
      body: JSON.stringify({ email, password })
    });
  },
  forgotPassword(email: string) {
    return apiRequest<{ message: string }>("/admin/auth/forgot-password", {
      method: "POST",
      body: JSON.stringify({ email })
    });
  },
  resetPassword(email: string, otp: string, newPassword: string) {
    return apiRequest<{ message: string }>("/admin/auth/reset-password", {
      method: "POST",
      body: JSON.stringify({ email, otp, newPassword })
    });
  },
  getDashboard(authToken: string) {
    return apiRequest<AdminDashboard>("/admin/dashboard", { authToken });
  },
  getBookings(authToken: string) {
    return apiRequest<AdminBooking[]>("/admin/bookings", { authToken });
  },
  getTours(authToken: string) {
    return apiRequest<AdminTour[]>("/admin/tours", { authToken });
  },
  getTour(authToken: string, id: string) {
    return apiRequest<AdminTour>(`/admin/tours/${id}`, { authToken });
  },
  createTour(authToken: string, payload: AdminTourPayload) {
    return apiRequest<AdminTour>("/admin/tours", {
      method: "POST",
      authToken,
      body: JSON.stringify(payload)
    });
  },
  updateTour(authToken: string, id: string, payload: AdminTourPayload) {
    return apiRequest<AdminTour>(`/admin/tours/${id}`, {
      method: "PUT",
      authToken,
      body: JSON.stringify(payload)
    });
  },
  deleteTour(authToken: string, id: string) {
    return apiRequest<void>(`/admin/tours/${id}`, {
      method: "DELETE",
      authToken
    });
  },
  getGuides(authToken: string) {
    return apiRequest<AdminGuide[]>("/admin/guides", { authToken });
  },
  getPasswordResetTemplate(authToken: string) {
    return apiRequest<AdminEmailTemplate>("/admin/email-templates/password-reset", { authToken });
  },
  getChat(authToken: string, userId?: string) {
    return apiRequest<AdminChat>(`/admin/chat${userId ? `?userId=${encodeURIComponent(userId)}` : ""}`, { authToken });
  },
  sendChatMessage(authToken: string, payload: AdminChatSendPayload) {
    return apiRequest<AdminChatMessage>("/admin/chat/messages", {
      method: "POST",
      authToken,
      body: JSON.stringify(payload)
    });
  },
  getBilling(authToken: string) {
    return apiRequest<AdminBilling>("/admin/billing", { authToken });
  },
  updatePayment(authToken: string, payload: { cardHolderName: string; cardNumber: string; provider: string }) {
    return apiRequest<AdminBilling>("/admin/billing/payment", {
      method: "PUT",
      authToken,
      body: JSON.stringify(payload)
    });
  },
  updatePlan(authToken: string, planName: string) {
    return apiRequest<AdminBilling>("/admin/billing/plan", {
      method: "PUT",
      authToken,
      body: JSON.stringify({ planName })
    });
  }
};
