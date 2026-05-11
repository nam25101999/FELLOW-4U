import {
  BarChart3,
  Bell,
  CalendarCheck2,
  CheckCircle2,
  ChevronDown,
  Compass,
  CreditCard,
  Headphones,
  LayoutDashboard,
  Mail,
  MessageSquareText,
  Menu,
  Plane,
  Search,
  ShieldCheck,
  Star,
  Tag,
  Upload,
  UsersRound,
  WalletCards,
  type LucideIcon
} from "lucide-react";
import { FormEvent, useEffect, useMemo, useState } from "react";
import {
  adminApi,
  type AdminActivity,
  type AdminBooking,
  type AdminDashboard,
  type AdminEmailTemplate,
  type AdminMetric
} from "./api/client";
import { AdminBillingPage, AdminChatPage, AdminDashboardPage, AdminTourFormPage, AdminToursPage } from "./admin/AdminPages";
import cloudLarge from "./assets/mobile/splash/CloudLarge.svg";
import cloudSmall from "./assets/mobile/splash/CloudSmall.svg";
import flightPath from "./assets/mobile/splash/FlightPath.svg";
import logoWhite from "./assets/mobile/splash/Logo.svg";
import planeAsset from "./assets/mobile/splash/Plane.svg";

const fallbackDashboard: AdminDashboard = {
  metrics: [
    { label: "Revenue", value: "$690", delta: "+12.8%", tone: "teal" },
    { label: "Bookings", value: "4", delta: "+24 today", tone: "blue" },
    { label: "Active tours", value: "20", delta: "20 guides", tone: "amber" },
    { label: "Open issues", value: "1", delta: "payment review", tone: "coral" }
  ],
  revenue: [
    { month: "Dec", revenue: 0 },
    { month: "Jan", revenue: 120 },
    { month: "Feb", revenue: 220 },
    { month: "Mar", revenue: 180 },
    { month: "Apr", revenue: 95 },
    { month: "May", revenue: 275 }
  ],
  recentBookings: [
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
    }
  ],
  topTours: [
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
    }
  ],
  topGuides: [
    {
      id: "GD-1",
      name: "Tuan Tran",
      location: "Da Nang",
      avatarUrl: "https://ui-avatars.com/api/?name=Tuan+Tran&background=00CEA6&color=ffffff",
      rating: 4.9,
      activeTrips: 8,
      responseRate: 98
    },
    {
      id: "GD-2",
      name: "Linh Hana",
      location: "Hanoi",
      avatarUrl: "https://ui-avatars.com/api/?name=Linh+Hana&background=2F80ED&color=ffffff",
      rating: 4.8,
      activeTrips: 6,
      responseRate: 94
    }
  ],
  activities: [
    { title: "New booking received", meta: "Dragon Bridge Trip", tone: "teal" },
    { title: "Payment review queue", meta: "1 unpaid booking", tone: "amber" },
    { title: "Top rated tour", meta: "Da Nang - Ba Na - Hoi An", tone: "blue" }
  ]
};

const fallbackTemplate: AdminEmailTemplate = {
  subject: "Reset your Fellow4U admin password",
  logoText: "Fellow4U",
  title: "Title Here: Lorem Ipsum is simply dummy text of the printing type specimen book",
  body:
    "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
  buttonLabel: "BUTTON",
  buttonUrl: "#",
  footer: "If this is a long established fact that a reader will be distracted by readable content of a page when looking at its layout."
};

function App() {
  const [path, setPath] = useState(window.location.pathname);

  useEffect(() => {
    const syncPath = () => setPath(window.location.pathname);
    window.addEventListener("popstate", syncPath);
    return () => window.removeEventListener("popstate", syncPath);
  }, []);

  if (path === "/admin/forgot-password") {
    return <ForgotPasswordPage />;
  }

  if (path === "/admin/sign-up" || path === "/admin/signup") {
    return <SignUpPage />;
  }

  if (path === "/admin/sign-up/plan" || path === "/admin/sign-up-plan") {
    return <ChoosePlanPage />;
  }

  if (path === "/admin/wait-approval" || path === "/admin/approval") {
    return <WaitApprovalPage />;
  }

  if (path === "/admin/check-email") {
    return <CheckEmailPage />;
  }

  if (path === "/admin/reset-password") {
    return <ResetPasswordPage />;
  }

  if (path === "/admin/email-template") {
    return <EmailTemplatePage />;
  }

  if (path === "/admin/dashboard") {
    return <AdminDashboardPage />;
  }

  if (path === "/admin/tours") {
    return <AdminToursPage />;
  }

  if (path === "/admin/chat") {
    return <AdminChatPage />;
  }

  if (path === "/admin/billing") {
    return <AdminBillingPage />;
  }

  if (path === "/admin/tours/new") {
    return <AdminTourFormPage />;
  }

  const editTourMatch = path.match(/^\/admin\/tours\/([^/]+)\/edit$/);
  if (editTourMatch) {
    return <AdminTourFormPage tourId={editTourMatch[1]} />;
  }

  return <SignInPage />;
}

function routeTo(path: string) {
  window.history.pushState({}, "", path);
  window.dispatchEvent(new PopStateEvent("popstate"));
}

function AuthShell({
  title,
  children,
  cardClassName = "min-h-[500px]",
  cardWidthClassName = "max-w-[420px]",
  contentClassName = "pt-10"
}: {
  title: string;
  children: React.ReactNode;
  cardClassName?: string;
  cardWidthClassName?: string;
  contentClassName?: string;
}) {
  return (
    <main className="min-h-screen bg-white" aria-label={title}>
      <section className="relative min-h-screen overflow-hidden bg-white">
        <div className="absolute inset-x-0 top-0 h-[330px] bg-brand">
          <img className="absolute left-[16%] top-16 w-20 opacity-40" src={cloudLarge} alt="" />
          <img className="absolute left-0 top-28 w-20 opacity-30" src={cloudSmall} alt="" />
          <img className="absolute right-[8%] top-12 w-28 opacity-20" src={planeAsset} alt="" />
          <img className="absolute right-[18%] top-24 w-36 opacity-20" src={flightPath} alt="" />
          <img className="absolute right-[15%] top-44 w-16 opacity-35" src={cloudSmall} alt="" />
          <div className="absolute -bottom-[62px] left-1/2 h-[136px] w-[125%] -translate-x-1/2 rounded-[50%] bg-white" />
        </div>

        <div className="relative z-10 flex justify-center pt-12">
          <img className="h-auto w-[118px]" src={logoWhite} alt="Fellow4U" />
        </div>

        <div className={`relative z-10 flex justify-center px-5 ${contentClassName}`}>
          <section
            className={`w-full ${cardWidthClassName} rounded-lg bg-white px-8 py-8 shadow-card ring-1 ring-black/5 md:px-12 ${cardClassName}`}
          >
            {children}
          </section>
        </div>
      </section>
    </main>
  );
}

function SignInPage() {
  const [email, setEmail] = useState("admin@fellow4u.com");
  const [password, setPassword] = useState("admin123");
  const [message, setMessage] = useState("");

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setMessage("");

    try {
      const response = await adminApi.login(email, password);
      localStorage.setItem("admin_token", response.token);
      routeTo("/admin/dashboard");
    } catch {
      setMessage("Cannot sign in right now. Check backend or admin credentials.");
    }
  }

  return (
    <AuthShell title="Sign In" cardClassName="min-h-[510px]">
      <form className="space-y-5" onSubmit={handleSubmit}>
        <div>
          <h2 className="text-2xl font-bold text-ink">Sign In</h2>
          <p className="mt-5 text-sm font-medium text-brand">Welcome back, Phuong Nam Tour</p>
        </div>

        <AuthField label="Email" value={email} onChange={setEmail} placeholder="Type email" type="email" />
        <div>
          <AuthField
            label="Password"
            value={password}
            onChange={setPassword}
            placeholder="Password"
            type="password"
          />
          <button
            className="mt-2 text-xs font-medium text-muted hover:text-brand"
            type="button"
            onClick={() => routeTo("/admin/forgot-password")}
          >
            Forgot Password
          </button>
        </div>

        {message ? <p className="rounded-md bg-coral/10 p-3 text-xs font-medium text-coral">{message}</p> : null}

        <button
          className="h-10 w-full rounded bg-brand text-xs font-bold text-white shadow-soft transition hover:bg-brand-dark"
          type="submit"
        >
          SIGN IN
        </button>

        <div className="pt-2 text-center">
          <p className="text-xs text-muted">or sign in with</p>
          <div className="mt-3 flex justify-center gap-2">
            <SocialButton label="f" className="bg-[#3568B8] text-white" />
            <SocialButton label="G" className="bg-[#FFE100] text-ink" />
            <SocialButton label="LINE" className="bg-[#43D044] text-ink" />
          </div>
          <p className="mt-6 text-xs text-muted">
            Don't have an account?{" "}
            <button className="font-bold text-brand" type="button" onClick={() => routeTo("/admin/sign-up")}>
              Sign Up
            </button>
          </p>
        </div>
      </form>
    </AuthShell>
  );
}

function SignUpPage() {
  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    routeTo("/admin/sign-up/plan");
  }

  return (
    <AuthShell
      title="Sign Up"
      cardClassName="min-h-[720px]"
      cardWidthClassName="max-w-[820px]"
      contentClassName="pt-7 pb-16"
    >
      <form className="space-y-7" onSubmit={handleSubmit}>
        <h2 className="text-2xl font-bold text-ink">Sign Up</h2>

        <div className="flex items-center gap-3">
          <button
            className="grid h-14 w-14 place-items-center rounded-full border border-brand text-brand transition hover:bg-brand/10"
            type="button"
            aria-label="Upload profile picture"
          >
            <Upload size={22} aria-hidden="true" />
          </button>
          <span className="text-xs leading-4 text-muted">
            upload
            <br />
            profile picture
          </span>
        </div>

        <div className="grid gap-x-20 gap-y-5 md:grid-cols-2">
          <SignUpField label="Company Name" placeholder="Phuong Nam Tour" />
          <PhoneField />
          <SignUpField label="Email" placeholder="Email" type="email" />
          <SignUpField label="Representative" placeholder="Representative Name" />
          <SignUpField
            label="Password"
            placeholder="Password"
            type="password"
            hint="Password has more than 8 letters"
          />
          <SignUpField label="Company registration number" placeholder="Registration number" />
          <SignUpField label="Confirm Password" placeholder="Confirm Password" type="password" />

          <div>
            <div className="mb-2 flex items-center gap-2">
              <span className="text-xs font-bold text-ink">Social Contact</span>
              <span className="text-xs font-semibold text-[#2F80ED]">(Optional)</span>
            </div>
            <div className="grid gap-2">
              <SocialContactInput color="bg-[#3568B8]" label="f" placeholder="Facebook" />
              <SocialContactInput color="bg-[#FFE100]" label="K" placeholder="Kakao Talk" textColor="text-ink" />
              <SocialContactInput color="bg-[#43D044]" label="LINE" placeholder="Line" textColor="text-ink" />
            </div>
          </div>

          <div>
            <SignUpField label="Company Address" placeholder="Address" />
            <div className="mt-2 grid grid-cols-2 gap-3">
              <SignUpField placeholder="City" />
              <SignUpField placeholder="Country" />
            </div>
          </div>
        </div>

        <div className="pt-5 text-center">
          <p className="text-xs text-muted">
            By Signing Up, you agree to our{" "}
            <button className="font-bold text-brand" type="button">
              Terms & Conditions
            </button>
          </p>
          <button
            className="mx-auto mt-4 grid h-11 w-full max-w-[280px] place-items-center rounded bg-brand text-xs font-bold text-white shadow-soft transition hover:bg-brand-dark"
            type="submit"
          >
            SIGN UP
          </button>
          <p className="mt-7 text-xs text-muted">
            Already have an account?{" "}
            <button className="font-bold text-brand" type="button" onClick={() => routeTo("/admin/sign-in")}>
              Sign In
            </button>
          </p>
        </div>
      </form>
    </AuthShell>
  );
}

function ChoosePlanPage() {
  const plans = [
    { name: "Starter", price: "100", selected: true },
    { name: "Basic", price: "120", selected: false },
    { name: "Premium", price: "180", selected: false }
  ];

  return (
    <AuthShell
      title="Choose Plan"
      cardClassName="min-h-[900px] px-0 md:px-0"
      cardWidthClassName="max-w-[1000px]"
      contentClassName="pt-7 pb-16"
    >
      <div className="px-8 md:px-20">
        <h2 className="text-2xl font-bold text-ink">Choose your plan</h2>
        <p className="mt-5 max-w-[640px] text-xs leading-5 text-muted">
          Almost there, please select a plan that's the most benefit for you. You will have one month trial and you can
          cancel the subscription at any time.
        </p>

        <section className="mt-8">
          <SectionLabel icon={CreditCard} label="Payment Info" />
          <div className="mx-auto mt-6 grid max-w-[430px] gap-5">
            <SignUpField label="Card Holder's Name" placeholder="Card Holder's Name" />
            <SignUpField label="Card Number" placeholder="0000 0000 0000 0000" />
            <div className="grid grid-cols-2 gap-10">
              <SignUpField label="Expiration Date" placeholder="mm/yy" />
              <SignUpField label="CVV" placeholder="000" />
            </div>
          </div>
        </section>
      </div>

      <div className="my-12 border-t border-line" />

      <div className="px-8 md:px-20">
        <SectionLabel icon={Tag} label="Plans" />
        <div className="mt-8 grid gap-6 md:grid-cols-3">
          {plans.map((plan) => (
            <PlanCard key={plan.name} name={plan.name} price={plan.price} selected={plan.selected} />
          ))}
        </div>

        <div className="mt-14 flex justify-center">
          <button
            className="h-11 rounded bg-brand px-10 text-xs font-bold text-white shadow-soft transition hover:bg-brand-dark"
            type="button"
            onClick={() => routeTo("/admin/wait-approval")}
          >
            TAKE SUBSCRIPTION
          </button>
        </div>
      </div>
    </AuthShell>
  );
}

function WaitApprovalPage() {
  return (
    <main className="min-h-screen bg-page">
      <header className="flex h-16 items-center gap-5 bg-brand px-8 text-white">
        <button className="mr-auto" type="button" onClick={() => routeTo("/admin/sign-in")} aria-label="Go to sign in">
          <img className="w-24" src={logoWhite} alt="Fellow4U" />
        </button>
        <Bell size={16} aria-hidden="true" />
        <button className="inline-flex h-7 items-center gap-2 rounded-full bg-white/15 px-3 text-xs font-medium" type="button">
          English
          <ChevronDown size={12} aria-hidden="true" />
        </button>
        <button className="inline-flex items-center gap-3 text-xs font-medium" type="button">
          <span className="grid h-8 w-8 place-items-center rounded-full bg-white text-brand">
            <Plane size={17} aria-hidden="true" />
          </span>
          Phuong Nam Tour
          <ChevronDown size={12} aria-hidden="true" />
        </button>
      </header>

      <div className="grid min-h-[calc(100vh-4rem)] grid-cols-1 lg:grid-cols-[240px_1fr]">
        <aside className="hidden border-r border-line bg-white px-8 py-10 lg:block">
          <nav className="grid gap-7">
            <ApprovalNav icon={LayoutDashboard} label="Dashboard" />
            <ApprovalNav icon={Compass} label="Tours" />
            <ApprovalNav icon={MessageSquareText} label="Chat" />
            <ApprovalNav icon={WalletCards} label="Billing History & Payment" />
            <ApprovalNav icon={Headphones} label="Support" />
          </nav>
        </aside>

        <section className="p-5 md:p-8">
          <article className="grid min-h-[560px] place-items-center rounded-lg bg-white p-8 shadow-card ring-1 ring-black/5">
            <div className="grid max-w-[560px] justify-items-center text-center">
              <div className="relative h-36 w-72">
                <img className="absolute left-10 top-9 w-44 opacity-70" src={flightPath} alt="" />
                <img className="absolute right-8 top-0 w-20" src={planeAsset} alt="" />
                <Star className="absolute left-16 top-2 fill-brand text-brand" size={22} aria-hidden="true" />
                <Star className="absolute left-32 bottom-6 fill-brand text-brand" size={18} aria-hidden="true" />
                <Star className="absolute right-32 top-12 fill-brand text-brand" size={16} aria-hidden="true" />
              </div>
              <p className="mt-10 max-w-[440px] text-sm leading-6 text-ink">
                Congratulations! Registered successfully! It will take a while for us to review your account. As soon as
                your account has been approved, you can upload the tours. Now you can explore another parts of our
                service in the Left Menu.
              </p>
            </div>
          </article>
        </section>
      </div>
    </main>
  );
}

function ForgotPasswordPage() {
  const [email, setEmail] = useState("admin@fellow4u.com");
  const [message, setMessage] = useState("");

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    sessionStorage.setItem("admin_reset_email", email);
    setMessage("");

    try {
      await adminApi.forgotPassword(email);
      routeTo("/admin/check-email");
    } catch {
      setMessage("Could not send reset instructions. Backend mail settings may need attention.");
    }
  }

  return (
    <AuthShell title="Forgot Password" cardClassName="min-h-[470px]">
      <form className="space-y-7" onSubmit={handleSubmit}>
        <div>
          <h2 className="text-2xl font-bold text-ink">Forgot Password</h2>
          <p className="mt-5 max-w-[260px] text-xs leading-5 text-muted">
            Input your email, we will send you an instruction to reset your password.
          </p>
        </div>
        <AuthField label="Email" value={email} onChange={setEmail} placeholder="your@email.com" type="email" />
        {message ? <p className="rounded-md bg-coral/10 p-3 text-xs font-medium text-coral">{message}</p> : null}
        <button
          className="h-10 w-full rounded bg-brand text-xs font-bold text-white shadow-soft transition hover:bg-brand-dark"
          type="submit"
        >
          SEND
        </button>
        <BackToSignIn />
      </form>
    </AuthShell>
  );
}

function CheckEmailPage() {
  return (
    <AuthShell title="Forgot Password-Check Email" cardClassName="min-h-[470px]">
      <div className="flex h-full flex-col">
        <h2 className="text-2xl font-bold text-ink">Check Email</h2>
        <p className="mt-5 max-w-[270px] text-xs leading-5 text-muted">
          Please check your email for the instructions on how to reset your password.
        </p>

        <div className="flex flex-1 items-center justify-center py-10">
          <div className="relative h-28 w-32">
            <div className="absolute left-1/2 top-0 h-16 w-16 -translate-x-1/2 rotate-45 rounded bg-brand shadow-soft" />
            <div className="absolute bottom-0 left-1/2 grid h-20 w-28 -translate-x-1/2 place-items-center rounded-lg bg-white shadow-card ring-1 ring-black/5">
              <Mail className="text-brand" size={42} aria-hidden="true" />
            </div>
          </div>
        </div>

        <BackToSignIn />
      </div>
    </AuthShell>
  );
}

function ResetPasswordPage() {
  const params = new URLSearchParams(window.location.search);
  const email = params.get("email") ?? sessionStorage.getItem("admin_reset_email") ?? "admin@fellow4u.com";
  const otp = params.get("otp") ?? "";
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [message, setMessage] = useState("");

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (newPassword !== confirmPassword) {
      setMessage("Passwords do not match.");
      return;
    }

    try {
      await adminApi.resetPassword(email, otp, newPassword);
      setMessage("Password has been reset. You can sign in again.");
    } catch {
      setMessage("Could not reset password. Make sure the reset link includes a valid OTP.");
    }
  }

  return (
    <AuthShell title="Reset Password" cardClassName="min-h-[430px]">
      <form className="space-y-7" onSubmit={handleSubmit}>
        <h2 className="text-2xl font-bold text-ink">Reset Password</h2>
        <AuthField
          label="New Password"
          value={newPassword}
          onChange={setNewPassword}
          placeholder="New Password"
          type="password"
        />
        <AuthField
          label="Confirm New Password"
          value={confirmPassword}
          onChange={setConfirmPassword}
          placeholder="Confirm New Password"
          type="password"
        />
        {message ? <p className="rounded-md bg-brand/10 p-3 text-xs font-medium text-brand-dark">{message}</p> : null}
        <button
          className="h-10 w-full rounded bg-brand text-xs font-bold text-white shadow-soft transition hover:bg-brand-dark"
          type="submit"
        >
          RESET PASSWORD
        </button>
      </form>
    </AuthShell>
  );
}

function EmailTemplatePage() {
  const [template, setTemplate] = useState<AdminEmailTemplate>(fallbackTemplate);

  useEffect(() => {
    const token = localStorage.getItem("admin_token");
    if (!token) {
      return;
    }

    adminApi.getPasswordResetTemplate(token).then(setTemplate).catch(() => setTemplate(fallbackTemplate));
  }, []);

  return (
    <main className="min-h-screen bg-white">
      <section className="mx-auto min-h-screen bg-white px-5 py-20">
        <article className="mx-auto max-w-[560px] rounded-lg bg-white px-12 py-10 shadow-card ring-1 ring-black/5">
          <BrandTextLogo />
          <h2 className="mt-10 text-lg font-bold leading-7 text-ink">{template.title}</h2>
          <p className="mt-5 text-sm leading-6 text-muted">{template.body}</p>
          <p className="mt-4 text-sm leading-6 text-muted">{template.body}</p>
          <p className="mt-4 text-sm leading-6 text-brand-dark">{template.footer}</p>
          <div className="mt-12 flex justify-center">
            <a
              className="grid h-9 min-w-28 place-items-center rounded bg-brand px-7 text-xs font-bold text-white shadow-soft hover:bg-brand-dark"
              href={template.buttonUrl}
            >
              {template.buttonLabel}
            </a>
          </div>
        </article>
      </section>
    </main>
  );
}

function DashboardPage() {
  const [dashboard, setDashboard] = useState<AdminDashboard>(fallbackDashboard);
  const [query, setQuery] = useState("");

  useEffect(() => {
    const token = localStorage.getItem("admin_token");
    if (!token) {
      return;
    }

    adminApi.getDashboard(token).then(setDashboard).catch(() => setDashboard(fallbackDashboard));
  }, []);

  const filteredBookings = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    if (!normalized) {
      return dashboard.recentBookings;
    }

    return dashboard.recentBookings.filter((booking) =>
      [booking.id, booking.tripTitle, booking.location, booking.guideName].join(" ").toLowerCase().includes(normalized)
    );
  }, [dashboard.recentBookings, query]);

  return (
    <main className="min-h-screen bg-page">
      <aside className="fixed inset-y-0 left-0 hidden w-64 border-r border-line bg-white px-4 py-6 lg:flex lg:flex-col">
        <div className="flex items-center gap-3 px-2">
          <span className="grid h-11 w-11 place-items-center rounded-lg bg-brand text-white shadow-soft">
            <Plane size={22} aria-hidden="true" />
          </span>
          <div>
            <strong className="block text-lg text-ink">Fellow4U</strong>
            <span className="text-sm text-muted">Admin</span>
          </div>
        </div>

        <nav className="mt-8 grid gap-2">
          <DashboardNav icon={LayoutDashboard} label="Dashboard" active />
          <DashboardNav icon={CalendarCheck2} label="Bookings" />
          <DashboardNav icon={Compass} label="Tours" />
          <DashboardNav icon={UsersRound} label="Guides" />
          <DashboardNav icon={WalletCards} label="Finance" />
          <DashboardNav icon={BarChart3} label="Reports" />
        </nav>
      </aside>

      <section className="lg:pl-64">
        <header className="sticky top-0 z-10 flex flex-wrap items-center gap-4 border-b border-line bg-page/90 px-5 py-4 backdrop-blur md:px-8">
          <button className="grid h-11 w-11 place-items-center rounded-lg border border-line bg-white text-ink lg:hidden" type="button">
            <Menu size={20} aria-hidden="true" />
          </button>
          <div className="mr-auto">
            <span className="text-xs font-bold uppercase text-muted">Operations</span>
            <h1 className="text-3xl font-bold text-ink">Dashboard</h1>
          </div>
          <label className="flex h-11 min-w-full items-center gap-3 rounded-lg border border-line bg-white px-4 text-muted md:min-w-[360px]">
            <Search size={18} aria-hidden="true" />
            <input
              className="w-full border-0 bg-transparent text-sm text-ink outline-none"
              placeholder="Search trips, guides, IDs"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
            />
          </label>
          <button className="grid h-11 w-11 place-items-center rounded-lg border border-line bg-white text-ink" type="button">
            <Bell size={20} aria-hidden="true" />
          </button>
        </header>

        <div className="mx-auto grid max-w-[1500px] gap-6 px-5 py-6 md:px-8">
          <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            {dashboard.metrics.map((metric) => (
              <MetricCard key={metric.label} metric={metric} />
            ))}
          </section>

          <section className="grid gap-6 xl:grid-cols-[1.35fr_0.65fr]">
            <Panel eyebrow="Performance" title="Revenue trend">
              <div className="flex h-64 items-end gap-3 rounded-lg bg-[#fbfcfe] p-4">
                {dashboard.revenue.map((point) => (
                  <div className="grid h-full flex-1 grid-rows-[1fr_auto] items-end gap-3 text-center" key={point.month}>
                    <span
                      className="block min-h-5 rounded-t-lg bg-gradient-to-b from-brand to-[#2F80ED]"
                      style={{ height: `${Math.max(10, (Number(point.revenue) / 500) * 100)}%` }}
                    />
                    <small className="text-xs font-bold text-muted">{point.month}</small>
                  </div>
                ))}
              </div>
            </Panel>

            <Panel eyebrow="Platform" title="Service health">
              <div className="grid gap-3">
                <HealthItem label="Admin API" value="Ready" />
                <HealthItem label="Auth role" value="ADMIN" />
                <HealthItem label="Data source" value="Live + fallback" />
              </div>
            </Panel>
          </section>

          <section className="grid gap-6 xl:grid-cols-[1fr_380px]">
            <Panel eyebrow="Trips" title="Recent bookings">
              <div className="overflow-x-auto">
                <table className="w-full min-w-[760px] border-collapse text-left">
                  <thead>
                    <tr className="border-b border-line text-xs uppercase text-muted">
                      <th className="py-3 pr-4">Booking</th>
                      <th className="py-3 pr-4">Guide</th>
                      <th className="py-3 pr-4">Date</th>
                      <th className="py-3 pr-4">Status</th>
                      <th className="py-3 pr-4">Payment</th>
                      <th className="py-3 pr-4 text-right">Fee</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredBookings.map((booking) => (
                      <BookingRow booking={booking} key={booking.id} />
                    ))}
                  </tbody>
                </table>
              </div>
            </Panel>

            <div className="grid gap-6">
              <Panel eyebrow="Supply" title="Guide workload">
                <div className="grid gap-3">
                  {dashboard.topGuides.slice(0, 4).map((guide) => (
                    <article className="grid grid-cols-[44px_1fr_auto] items-center gap-3 rounded-lg border border-line p-3" key={guide.id}>
                      <img className="h-11 w-11 rounded-lg object-cover" src={guide.avatarUrl} alt="" />
                      <div>
                        <strong className="block text-sm text-ink">{guide.name}</strong>
                        <span className="text-xs text-muted">{guide.location}</span>
                      </div>
                      <span className="inline-flex items-center gap-1 text-sm font-bold text-[#996F00]">
                        <Star size={14} aria-hidden="true" />
                        {guide.rating.toFixed(1)}
                      </span>
                    </article>
                  ))}
                </div>
              </Panel>

              <Panel eyebrow="Live feed" title="Activity">
                <div className="grid gap-3">
                  {dashboard.activities.map((activity) => (
                    <ActivityRow activity={activity} key={activity.title} />
                  ))}
                </div>
              </Panel>
            </div>
          </section>

          <Panel eyebrow="Inventory" title="Top tours">
            <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
              {dashboard.topTours.slice(0, 6).map((tour) => (
                <article className="overflow-hidden rounded-lg border border-line bg-white" key={tour.id}>
                  <img className="aspect-video w-full object-cover" src={tour.imageUrl} alt="" />
                  <div className="grid gap-3 p-4">
                    <span className="w-fit rounded-full bg-brand/10 px-3 py-1 text-xs font-bold text-brand-dark">
                      {tour.category.replace("_", " ")}
                    </span>
                    <h3 className="text-lg font-bold text-ink">{tour.title}</h3>
                    <div className="flex items-center justify-between gap-3">
                      <strong className="text-lg text-ink">${tour.price}</strong>
                      <span className="inline-flex items-center gap-1 text-sm font-bold text-[#996F00]">
                        <Star size={14} aria-hidden="true" />
                        {tour.rating}
                      </span>
                    </div>
                    <div className="h-2 overflow-hidden rounded-full bg-[#EDF1F6]">
                      <span className="block h-full rounded-full bg-gradient-to-r from-brand to-[#2F80ED]" style={{ width: `${tour.bookingRate}%` }} />
                    </div>
                  </div>
                </article>
              ))}
            </div>
          </Panel>
        </div>
      </section>
    </main>
  );
}

function AuthField({
  label,
  value,
  onChange,
  placeholder,
  type
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  placeholder: string;
  type: string;
}) {
  return (
    <label className="block">
      <span className="mb-1 block text-xs font-bold text-ink">{label}</span>
      <input
        className="h-8 w-full border-0 border-b border-[#d6d6d6] bg-transparent px-0 text-sm text-ink outline-none placeholder:text-[#9d9d9d] focus:border-brand focus:ring-0"
        value={value}
        onChange={(event) => onChange(event.target.value)}
        placeholder={placeholder}
        type={type}
      />
    </label>
  );
}

function SignUpField({
  label,
  placeholder,
  type = "text",
  hint
}: {
  label?: string;
  placeholder: string;
  type?: string;
  hint?: string;
}) {
  return (
    <label className="block">
      {label ? <span className="mb-1 block text-xs font-bold text-ink">{label}</span> : null}
      <input
        className="h-8 w-full border-0 border-b border-[#cfd4dc] bg-transparent px-0 text-xs text-ink outline-none placeholder:text-muted focus:border-brand focus:ring-0"
        placeholder={placeholder}
        type={type}
      />
      {hint ? <span className="mt-1 block text-[10px] text-muted">{hint}</span> : null}
    </label>
  );
}

function PhoneField() {
  return (
    <label className="block">
      <span className="mb-1 block text-xs font-bold text-ink">Phone number</span>
      <div className="grid h-8 grid-cols-[auto_1fr] items-center gap-2 border-b border-[#cfd4dc] text-xs">
        <span className="font-semibold text-ink">(+84)</span>
        <input
          className="h-full border-0 bg-transparent px-0 text-ink outline-none placeholder:text-muted focus:ring-0"
          placeholder="Phone number"
          type="tel"
        />
      </div>
    </label>
  );
}

function SocialContactInput({
  color,
  label,
  placeholder,
  textColor = "text-white"
}: {
  color: string;
  label: string;
  placeholder: string;
  textColor?: string;
}) {
  return (
    <label className="grid grid-cols-[18px_1fr] items-center gap-2 border-b border-[#cfd4dc] pb-1">
      <span className={`grid h-5 w-5 place-items-center rounded text-[8px] font-black ${color} ${textColor}`}>
        {label}
      </span>
      <input
        className="h-6 border-0 bg-transparent text-xs text-ink outline-none placeholder:text-muted focus:ring-0"
        placeholder={placeholder}
        type="text"
      />
    </label>
  );
}

function SectionLabel({ icon: Icon, label }: { icon: LucideIcon; label: string }) {
  return (
    <div className="inline-flex items-center gap-3 text-lg font-bold text-ink">
      <Icon size={18} aria-hidden="true" />
      <span>{label}</span>
    </div>
  );
}

function PlanCard({ name, price, selected }: { name: string; price: string; selected: boolean }) {
  return (
    <article className="relative overflow-hidden rounded-lg border border-line bg-white shadow-card">
      <span
        className={`absolute right-[-8px] top-[-8px] grid h-9 w-9 place-items-center rounded-full ${
          selected ? "bg-[#7CB342] text-white" : "bg-[#D6D8DC] text-white"
        }`}
      >
        <CheckCircle2 size={18} aria-hidden="true" />
      </span>
      <header className="bg-brand px-6 py-5 text-center text-white">
        <h3 className="text-lg font-bold">{name}</h3>
        <p className="mt-3 text-sm">
          $ <strong className="text-4xl font-medium">{price}</strong> /year
        </p>
      </header>
      <div className="divide-y divide-line px-5 text-xs leading-5 text-muted">
        <p className="py-3">Lorem Ipsum is simply dummy text of the printing and typesetting industry</p>
        <p className="py-3">Lorem Ipsum has been the industry's standard dummy text ever</p>
        <p className="py-3">Since the 1500s, when an unknown printer took a galley of type</p>
        <p className="py-3">It has survived not only five centuries</p>
        <p className="py-3">But also the leap into electronic typesetting, remaining essentially</p>
      </div>
    </article>
  );
}

function ApprovalNav({ icon: Icon, label }: { icon: LucideIcon; label: string }) {
  return (
    <button className="flex items-center gap-3 text-sm font-medium text-muted hover:text-brand-dark" type="button">
      <Icon size={17} aria-hidden="true" />
      <span>{label}</span>
    </button>
  );
}

function BackToSignIn() {
  return (
    <div className="pt-8 text-center">
      <button className="text-xs text-muted" type="button" onClick={() => routeTo("/admin/sign-in")}>
        Back to <span className="font-bold text-brand">Sign In</span>
      </button>
    </div>
  );
}

function SocialButton({ label, className }: { label: string; className: string }) {
  return (
    <button className={`grid h-6 min-w-6 place-items-center rounded text-[10px] font-black ${className}`} type="button">
      {label}
    </button>
  );
}

function BrandTextLogo() {
  return (
    <div className="flex items-center gap-1 text-brand">
      <span className="text-lg font-medium leading-none">
        Fellow
        <br />
        <strong>4U</strong>
      </span>
      <span className="grid h-6 w-6 place-items-center rounded-full border-4 border-brand text-[10px] font-black">b</span>
    </div>
  );
}

function DashboardNav({ icon: Icon, label, active = false }: { icon: LucideIcon; label: string; active?: boolean }) {
  return (
    <button
      className={`flex h-11 items-center gap-3 rounded-lg px-3 text-sm font-semibold ${
        active ? "bg-brand/10 text-brand-dark" : "text-muted hover:bg-brand/10 hover:text-brand-dark"
      }`}
      type="button"
    >
      <Icon size={18} aria-hidden="true" />
      {label}
    </button>
  );
}

function MetricCard({ metric }: { metric: AdminMetric }) {
  const toneClasses: Record<AdminMetric["tone"], string> = {
    teal: "bg-brand/10 text-brand-dark",
    blue: "bg-[#2F80ED]/10 text-[#2F80ED]",
    amber: "bg-amber/20 text-[#8F6600]",
    coral: "bg-coral/10 text-coral"
  };

  return (
    <article className="rounded-lg border border-line bg-white p-5 shadow-card">
      <div className="flex items-start gap-4">
        <span className={`grid h-11 w-11 place-items-center rounded-lg ${toneClasses[metric.tone]}`}>
          <CheckCircle2 size={20} aria-hidden="true" />
        </span>
        <div>
          <span className="text-sm text-muted">{metric.label}</span>
          <strong className="mt-2 block text-3xl text-ink">{metric.value}</strong>
          <small className="mt-1 block text-sm text-muted">{metric.delta}</small>
        </div>
      </div>
    </article>
  );
}

function Panel({ eyebrow, title, children }: { eyebrow: string; title: string; children: React.ReactNode }) {
  return (
    <section className="rounded-lg border border-line bg-white p-5 shadow-card">
      <div className="mb-5 flex items-start justify-between gap-4">
        <div>
          <span className="text-xs font-bold uppercase text-muted">{eyebrow}</span>
          <h2 className="mt-1 text-xl font-bold text-ink">{title}</h2>
        </div>
        <ShieldCheck className="text-brand-dark" size={22} aria-hidden="true" />
      </div>
      {children}
    </section>
  );
}

function HealthItem({ label, value }: { label: string; value: string }) {
  return (
    <div className="flex min-h-14 items-center justify-between rounded-lg border border-line px-4">
      <span className="text-sm text-muted">{label}</span>
      <strong className="text-sm text-ink">{value}</strong>
    </div>
  );
}

function BookingRow({ booking }: { booking: AdminBooking }) {
  return (
    <tr className="border-b border-line last:border-b-0">
      <td className="py-4 pr-4">
        <strong className="block text-sm text-ink">{booking.tripTitle}</strong>
        <span className="text-xs text-muted">
          {booking.id} · {booking.location}
        </span>
      </td>
      <td className="py-4 pr-4 text-sm text-muted">{booking.guideName}</td>
      <td className="py-4 pr-4 text-sm text-muted">
        {new Intl.DateTimeFormat("en", { month: "short", day: "numeric" }).format(new Date(booking.date))}
      </td>
      <td className="py-4 pr-4">
        <Badge value={booking.status} />
      </td>
      <td className="py-4 pr-4">
        <Badge value={booking.paymentStatus} />
      </td>
      <td className="py-4 pr-4 text-right text-sm font-bold text-ink">${booking.totalFee}</td>
    </tr>
  );
}

function Badge({ value }: { value: string }) {
  const isDanger = value === "UNPAID";
  const isWarning = value === "PAID_50";
  const className = isDanger
    ? "bg-coral/10 text-coral"
    : isWarning
      ? "bg-amber/20 text-[#8F6600]"
      : "bg-brand/10 text-brand-dark";

  return <span className={`inline-flex min-h-7 items-center rounded-full px-3 text-xs font-bold ${className}`}>{value.replace("_", " ")}</span>;
}

function ActivityRow({ activity }: { activity: AdminActivity }) {
  const colorClasses: Record<AdminActivity["tone"], string> = {
    teal: "bg-brand",
    blue: "bg-[#2F80ED]",
    amber: "bg-amber",
    coral: "bg-coral"
  };

  return (
    <article className="grid grid-cols-[auto_1fr] items-center gap-3 rounded-lg border border-line p-3">
      <span className={`h-3 w-3 rounded-full ${colorClasses[activity.tone]}`} />
      <div>
        <strong className="block text-sm text-ink">{activity.title}</strong>
        <span className="text-xs text-muted">{activity.meta}</span>
      </div>
    </article>
  );
}

export default App;
