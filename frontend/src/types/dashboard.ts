import type { LucideIcon } from "lucide-react";

export type StatCard = {
  label: string;
  value: string;
  delta: string;
  trend: "up" | "down";
  tone: "teal" | "amber" | "blue" | "coral";
};

export type NavItem = {
  label: string;
  icon: LucideIcon;
};

export type BookingStatus = "CURRENT" | "NEXT" | "PAST" | "WISH_LIST";
export type PaymentStatus = "PAID_100" | "PAID_50" | "UNPAID";

export type Booking = {
  id: string;
  tripTitle: string;
  location: string;
  date: string;
  guideName: string;
  travelers: number;
  totalFee: number;
  status: BookingStatus;
  paymentStatus: PaymentStatus;
};

export type Tour = {
  id: string;
  title: string;
  location: string;
  imageUrl: string;
  price: number;
  category: "TOP_JOURNEY" | "FEATURED" | "REGULAR";
  rating: number;
  reviewCount: number;
  bookingRate: number;
};

export type Guide = {
  name: string;
  location: string;
  avatarUrl: string;
  rating: number;
  activeTrips: number;
  responseRate: number;
};

export type Activity = {
  title: string;
  meta: string;
  tone: "teal" | "amber" | "blue" | "coral";
};

export type RevenuePoint = {
  month: string;
  revenue: number;
};
