import type { Activity, Booking, Guide, RevenuePoint, StatCard, Tour } from "../types/dashboard";

export const statCards: StatCard[] = [
  {
    label: "Revenue",
    value: "$18.4K",
    delta: "+12.8%",
    trend: "up",
    tone: "teal"
  },
  {
    label: "Bookings",
    value: "328",
    delta: "+24 today",
    trend: "up",
    tone: "blue"
  },
  {
    label: "Active tours",
    value: "42",
    delta: "+6 live",
    trend: "up",
    tone: "amber"
  },
  {
    label: "Open issues",
    value: "7",
    delta: "-3 this week",
    trend: "down",
    tone: "coral"
  }
];

export const bookings: Booking[] = [
  {
    id: "BK-1048",
    tripTitle: "Dragon Bridge Trip",
    location: "Da Nang, Vietnam",
    date: "2026-05-11",
    guideName: "Tuan Tran",
    travelers: 2,
    totalFee: 120,
    status: "CURRENT",
    paymentStatus: "PAID_100"
  },
  {
    id: "BK-1049",
    tripTitle: "Ha Long Bay Cruise",
    location: "Ha Long, Vietnam",
    date: "2026-05-13",
    guideName: "Linh Hana",
    travelers: 4,
    totalFee: 360,
    status: "NEXT",
    paymentStatus: "PAID_50"
  },
  {
    id: "BK-1050",
    tripTitle: "Saigon Street Food",
    location: "Ho Chi Minh City, Vietnam",
    date: "2026-05-15",
    guideName: "Khai Ho",
    travelers: 3,
    totalFee: 210,
    status: "NEXT",
    paymentStatus: "UNPAID"
  },
  {
    id: "BK-1038",
    tripTitle: "Hue Royal Heritage",
    location: "Hue, Vietnam",
    date: "2026-04-27",
    guideName: "Ngoc Diep",
    travelers: 1,
    totalFee: 95,
    status: "PAST",
    paymentStatus: "PAID_100"
  }
];

export const tours: Tour[] = [
  {
    id: "TR-200",
    title: "Da Nang - Ba Na - Hoi An",
    location: "Da Nang",
    imageUrl: "http://127.0.0.1:8080/uploads/location/images.jpg",
    price: 125,
    category: "TOP_JOURNEY",
    rating: 4.9,
    reviewCount: 218,
    bookingRate: 86
  },
  {
    id: "TR-201",
    title: "Hanoi City Discovery",
    location: "Hanoi",
    imageUrl: "http://127.0.0.1:8080/uploads/location/tải xuống (4).jpg",
    price: 105,
    category: "FEATURED",
    rating: 4.8,
    reviewCount: 174,
    bookingRate: 74
  },
  {
    id: "TR-202",
    title: "Saigon Street Food",
    location: "Ho Chi Minh City",
    imageUrl: "http://127.0.0.1:8080/uploads/location/tải xuống (2).jpg",
    price: 88,
    category: "FEATURED",
    rating: 4.7,
    reviewCount: 132,
    bookingRate: 69
  }
];

export const guides: Guide[] = [
  {
    name: "Tuan Tran",
    location: "Da Nang",
    avatarUrl: "https://ui-avatars.com/api/?name=Tuan+Tran&background=00CEA6&color=ffffff",
    rating: 4.9,
    activeTrips: 8,
    responseRate: 98
  },
  {
    name: "Linh Hana",
    location: "Hanoi",
    avatarUrl: "https://ui-avatars.com/api/?name=Linh+Hana&background=2F80ED&color=ffffff",
    rating: 4.8,
    activeTrips: 6,
    responseRate: 94
  },
  {
    name: "Khai Ho",
    location: "Ho Chi Minh City",
    avatarUrl: "https://ui-avatars.com/api/?name=Khai+Ho&background=FFC100&color=121212",
    rating: 4.7,
    activeTrips: 5,
    responseRate: 91
  }
];

export const activities: Activity[] = [
  {
    title: "New payment captured",
    meta: "BK-1048 settled at 100%",
    tone: "teal"
  },
  {
    title: "Guide assignment needed",
    meta: "Saigon Street Food has 3 travelers",
    tone: "amber"
  },
  {
    title: "High rating received",
    meta: "Da Nang tour scored 4.9",
    tone: "blue"
  },
  {
    title: "Refund request opened",
    meta: "1 pending operator review",
    tone: "coral"
  }
];

export const revenuePoints: RevenuePoint[] = [
  { month: "Jan", revenue: 8200 },
  { month: "Feb", revenue: 11200 },
  { month: "Mar", revenue: 9700 },
  { month: "Apr", revenue: 14800 },
  { month: "May", revenue: 18400 },
  { month: "Jun", revenue: 16900 }
];
