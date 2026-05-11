import {
  Bell,
  ChevronDown,
  CreditCard,
  Edit3,
  Globe2,
  Grid2X2,
  Headphones,
  Image,
  MessageSquare,
  Mic,
  MoreHorizontal,
  NotebookTabs,
  Play,
  Search,
  Send,
  Trash2,
  X,
  Upload,
  type LucideIcon
} from "lucide-react";
import { FormEvent, useEffect, useMemo, useState } from "react";
import { adminApi, type AdminBilling, type AdminChat, type AdminChatMessage, type AdminDashboard, type AdminTour, type AdminTourPayload } from "../api/client";
import logoWhite from "../assets/mobile/splash/Logo.svg";

const tokenKey = "admin_token";

const emptyDashboard: AdminDashboard = {
  metrics: [],
  revenue: [],
  recentBookings: [],
  topTours: [],
  topGuides: [],
  activities: []
};

type AdminPage = "dashboard" | "tours" | "tour-new" | "tour-edit" | "chat" | "billing";

const emptyChat: AdminChat = {
  conversations: [],
  messages: []
};

const emptyBilling: AdminBilling = {
  invoices: [],
  paymentInfo: { cardHolderName: "", cardNumberMasked: "", provider: "", type: "CARD" },
  subscription: { planName: "", yearlyPrice: 0 },
  plans: []
};

const sampleImageUrls = [
  "http://127.0.0.1:8080/uploads/location/images.jpg",
  "http://127.0.0.1:8080/uploads/location/tải xuống (1).jpg",
  "http://127.0.0.1:8080/uploads/location/tải xuống (3).jpg"
];

export function AdminDashboardPage() {
  const [dashboard, setDashboard] = useState<AdminDashboard>(emptyDashboard);

  useEffect(() => {
    const token = localStorage.getItem(tokenKey);
    if (!token) {
      return;
    }

    adminApi.getDashboard(token).then(setDashboard).catch(() => setDashboard(emptyDashboard));
  }, []);

  const totalTours = metricValue(dashboard, "Total Tours");
  const savedTours = metricValue(dashboard, "Saved to Wishlist Tours");
  const chartValues = dashboard.revenue.length ? dashboard.revenue.map((item) => Number(item.revenue)) : Array.from({ length: 12 }, () => 0);
  const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

  return (
    <AdminShell active="dashboard">
      <div className="grid gap-6">
        <h1 className="text-2xl font-semibold text-black">Dashboard</h1>
        <section className="grid gap-6 md:grid-cols-2 lg:max-w-[690px]">
          <StatTile icon={Globe2} label="Total Tours" value={String(totalTours)} tone="teal" />
          <StatTile icon={NotebookTabs} label="Saved to Wishlist Tours" value={String(savedTours)} tone="amber" />
        </section>
        <section className="rounded-md bg-white p-8 shadow-sm ring-1 ring-black/5">
          <h2 className="mb-8 text-lg font-medium text-[#555]">Booked Tours</h2>
          <LineChart values={chartValues} labels={months} />
        </section>
      </div>
    </AdminShell>
  );
}

export function AdminToursPage() {
  const [tours, setTours] = useState<AdminTour[]>([]);
  const [query, setQuery] = useState("");
  const [openMenu, setOpenMenu] = useState<string | null>(null);

  useEffect(() => {
    refreshTours(setTours);
  }, []);

  const filteredTours = useMemo(() => {
    const normalized = query.trim().toLowerCase();
    if (!normalized) {
      return tours;
    }
    return tours.filter((tour) => [tour.id, tour.title, tour.location, tour.category].join(" ").toLowerCase().includes(normalized));
  }, [query, tours]);

  async function handleDelete(id: string) {
    const token = localStorage.getItem(tokenKey);
    if (!token) {
      setTours((items) => items.filter((tour) => tour.id !== id));
      return;
    }

    await adminApi.deleteTour(token, id);
    setTours((items) => items.filter((tour) => tour.id !== id));
  }

  return (
    <AdminShell active="tours">
      <header className="mb-6 flex items-center gap-4">
        <h1 className="mr-auto text-2xl font-semibold text-black">Tours</h1>
        <button className="h-10 rounded bg-brand px-7 text-xs font-bold text-white shadow-soft" type="button" onClick={() => navigate("/admin/tours/new")}>
          ADD TOUR
        </button>
      </header>

      {tours.length === 0 ? (
        <EmptyTours />
      ) : (
        <section className="rounded-md bg-white p-6 shadow-sm ring-1 ring-black/5">
          <div className="mb-5 flex flex-wrap items-center gap-4">
            <select className="h-8 rounded border border-line bg-white px-3 text-xs text-muted">
              <option>20 row</option>
              <option>50 row</option>
            </select>
            <label className="ml-auto flex h-8 min-w-[230px] items-center gap-2 rounded-full border border-line bg-white px-3 text-xs text-muted">
              <Search size={14} />
              <input className="w-full bg-transparent outline-none" placeholder="Search Tour" value={query} onChange={(event) => setQuery(event.target.value)} />
            </label>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full min-w-[840px] border-collapse text-left text-xs">
              <thead>
                <tr className="border-y border-line text-[#555]">
                  <th className="w-8 py-3"><input type="checkbox" /></th>
                  <th className="py-3">Tour ID</th>
                  <th className="py-3">Tour Name</th>
                  <th className="py-3">City</th>
                  <th className="py-3">Show/Hide</th>
                  <th className="py-3">Date Start</th>
                  <th className="py-3">Price</th>
                  <th className="py-3">Reviews</th>
                  <th className="py-3 text-right">Action</th>
                </tr>
              </thead>
              <tbody>
                {filteredTours.map((tour) => (
                  <tr className="border-b border-line last:border-b-0" key={tour.id}>
                    <td className="py-3"><input type="checkbox" /></td>
                    <td className="py-3 font-medium text-[#555]">{shortId(tour.id)}</td>
                    <td className="max-w-[270px] truncate py-3 text-[#333]">{tour.title}</td>
                    <td className="py-3 text-muted">{cityOf(tour.location)}</td>
                    <td className="py-3"><Toggle enabled /></td>
                    <td className="py-3 text-muted">{formatDate(tour.startDate)}</td>
                    <td className="py-3 text-muted">{Math.round(Number(tour.price || 0))}$</td>
                    <td className="py-3 text-muted">{tour.reviewCount || 0}</td>
                    <td className="relative py-3 text-right">
                      <button className="rounded p-1 text-muted hover:bg-page" type="button" onClick={() => setOpenMenu(openMenu === tour.id ? null : tour.id)} aria-label="Tour actions">
                        <MoreHorizontal size={18} />
                      </button>
                      {openMenu === tour.id ? (
                        <div className="absolute right-2 top-9 z-10 w-36 rounded bg-white py-2 text-left shadow-card ring-1 ring-black/5">
                          <button className="flex w-full items-center gap-2 px-3 py-2 text-xs text-ink hover:bg-page" type="button" onClick={() => navigate(`/admin/tours/${tour.id}/edit`)}>
                            <Edit3 size={13} /> Edit Tour
                          </button>
                          <button className="flex w-full items-center gap-2 px-3 py-2 text-xs text-coral hover:bg-page" type="button" onClick={() => handleDelete(tour.id)}>
                            <Trash2 size={13} /> Delete Tour
                          </button>
                        </div>
                      ) : null}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="mt-5 flex justify-end gap-2 text-xs">
            {[1, 2, 3].map((page) => (
              <button className={`grid h-7 w-7 place-items-center rounded ${page === 2 ? "bg-brand text-white" : "bg-[#333] text-white"}`} type="button" key={page}>
                {page}
              </button>
            ))}
          </div>
        </section>
      )}
    </AdminShell>
  );
}

export function AdminTourFormPage({ tourId }: { tourId?: string }) {
  const [form, setForm] = useState<AdminTourPayload>({
    title: "",
    description: "",
    imageUrl: "",
    price: 0,
    location: "",
    duration: "",
    startDate: "",
    rating: 4.5,
    reviewCount: 0,
    category: "REGULAR"
  });
  const [message, setMessage] = useState("");

  useEffect(() => {
    if (!tourId) {
      return;
    }

    const token = localStorage.getItem(tokenKey);
    if (!token) {
      return;
    }

    adminApi.getTour(token, tourId).then((tour) => setForm(toPayload(tour))).catch(() => setMessage("Cannot load tour right now."));
  }, [tourId]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setMessage("");
    const token = localStorage.getItem(tokenKey);

    try {
      if (token && tourId) {
        await adminApi.updateTour(token, tourId, normalizePayload(form));
      } else if (token) {
        await adminApi.createTour(token, normalizePayload(form));
      }
      navigate("/admin/tours");
    } catch {
      setMessage("Cannot save tour right now. Check backend connection and required fields.");
    }
  }

  return (
    <AdminShell active="tours" narrow>
      <h1 className="mb-5 text-xl font-semibold text-black">Add Tour</h1>
      <form className="rounded-sm bg-white shadow-sm ring-1 ring-black/5" onSubmit={handleSubmit}>
        <section className="grid gap-10 p-8 lg:grid-cols-2">
          <div className="grid gap-6">
            <SectionTitle>Tour Information</SectionTitle>
            <AdminField label="Tour Name" value={form.title} onChange={(value) => setForm({ ...form, title: value })} placeholder="Explore Seoul and Gyeongbokgung" />
            <div className="grid grid-cols-2 gap-5">
              <AdminSelect label="Category" value={form.category || "REGULAR"} onChange={(value) => setForm({ ...form, category: value })} options={["TOP_JOURNEY", "FEATURED", "REGULAR"]} />
              <AdminField label="Country" value={countryOf(form.location)} onChange={(value) => setForm({ ...form, location: joinLocation(cityOf(form.location), value) })} placeholder="South Korea" />
            </div>
            <AdminField label="City" value={cityOf(form.location)} onChange={(value) => setForm({ ...form, location: joinLocation(value, countryOf(form.location)) })} placeholder="Seoul" />
            <AdminSelect label="Language used in tour" value="English" onChange={() => undefined} options={["English", "Korean", "Japanese", "Chinese"]} />
            <AdminField label="Service Link" value={form.imageUrl || ""} onChange={(value) => setForm({ ...form, imageUrl: value })} placeholder="Paste image URL" />
            <UploadBox />
          </div>

          <div className="grid content-start gap-6">
            <AdminField label="Itinerary" value={form.description || ""} onChange={(value) => setForm({ ...form, description: value })} placeholder="Gyeongbokgung - Bukchon - Namsan" />
            <div className="grid grid-cols-2 gap-5">
              <AdminField label="Duration" value={form.duration || ""} onChange={(value) => setForm({ ...form, duration: value })} placeholder="2 days" />
              <AdminField label="Start Date" type="date" value={form.startDate || ""} onChange={(value) => setForm({ ...form, startDate: value })} />
            </div>
            <AdminField label="Departure" value={cityOf(form.location)} onChange={(value) => setForm({ ...form, location: joinLocation(value, countryOf(form.location)) })} placeholder="Seoul Station" />
            <SocialContact />
          </div>
        </section>

        <section className="border-t border-line p-8">
          <SectionTitle>Description</SectionTitle>
          <textarea className="mt-4 h-28 w-full resize-none rounded border border-line p-3 text-xs outline-none focus:border-brand" value={form.description || ""} onChange={(event) => setForm({ ...form, description: event.target.value })} placeholder="Short description before Tour" />
        </section>

        <section className="border-t border-line p-8">
          <SectionTitle>Tour Price</SectionTitle>
          <div className="mt-4 w-full max-w-[360px] overflow-hidden rounded border border-line text-xs">
            <PriceRow label="Adult (>10 years old)" value={String(form.price || "")} onChange={(value) => setForm({ ...form, price: Number(value) || 0 })} />
            <PriceRow label="Child (4-10 years old)" value={String(Math.round((form.price || 0) * 0.7))} onChange={() => undefined} />
            <PriceRow label="Discount" value="10" onChange={() => undefined} suffix="%" />
          </div>
        </section>

        <section className="border-t border-line p-8">
          <SectionTitle>Gallery</SectionTitle>
          <div className="mt-4 flex flex-wrap gap-3">
            <UploadBox compact />
            {(form.imageUrl ? [form.imageUrl] : []).map((url) => (
              <img className="h-20 w-28 rounded object-cover" src={url} alt="" key={url} />
            ))}
          </div>
        </section>

        <section className="border-t border-line p-8">
          <SectionTitle>Schedule</SectionTitle>
          <div className="mt-4 flex flex-wrap gap-6 text-xs text-muted">
            {["English", "Korean", "Japanese", "Chinese"].map((language, index) => (
              <label className="inline-flex items-center gap-2" key={language}>
                <input type="radio" checked={index === 0} readOnly />
                {language}
              </label>
            ))}
          </div>
          <div className="mt-4 flex flex-wrap items-center gap-3">
            <button className="h-8 rounded bg-brand px-6 text-xs font-bold text-white" type="button">Sun</button>
            {["Mon", "Tue"].map((day) => <button className="h-8 rounded border border-line px-5 text-xs text-muted" type="button" key={day}>{day}</button>)}
            <button className="text-xs font-bold text-brand" type="button">+ Add another Day</button>
          </div>
          <AdminField className="mt-4 max-w-[380px]" label="Date Summary" value={form.duration || ""} onChange={(value) => setForm({ ...form, duration: value })} placeholder="Daily tour" />
        </section>

        <section className="border-t border-line p-8">
          <SectionTitle>Other Information</SectionTitle>
          <textarea className="mt-4 h-28 w-full max-w-[380px] resize-none rounded border border-line p-3 text-xs outline-none focus:border-brand" placeholder="Accompanied Services" />
          <textarea className="mt-4 block h-28 w-full max-w-[380px] resize-none rounded border border-line p-3 text-xs outline-none focus:border-brand" placeholder="Notes" />
        </section>

        {message ? <p className="mx-8 rounded bg-coral/10 p-3 text-xs font-medium text-coral">{message}</p> : null}

        <footer className="flex justify-center gap-4 border-t border-line p-7">
          <button className="h-9 min-w-28 rounded border border-brand px-7 text-xs font-bold text-brand" type="button" onClick={() => navigate("/admin/tours")}>
            CANCEL
          </button>
          <button className="h-9 min-w-28 rounded bg-brand px-7 text-xs font-bold text-white shadow-soft" type="submit">
            SAVE
          </button>
        </footer>
      </form>
    </AdminShell>
  );
}

export function AdminChatPage() {
  const [chat, setChat] = useState<AdminChat>(emptyChat);
  const [draft, setDraft] = useState("");
  const [pendingImages, setPendingImages] = useState<string[]>([]);
  const [previewImage, setPreviewImage] = useState<string | null>(null);
  const [recording, setRecording] = useState(false);
  const [recordingSeconds, setRecordingSeconds] = useState(12);
  const activeUserId = chat.activeConversation?.userId;

  useEffect(() => {
    refreshChat(setChat);
  }, []);

  async function sendText() {
    if (!activeUserId || !draft.trim()) {
      return;
    }
    await sendMessage(setChat, {
      receiverId: activeUserId,
      type: "text",
      text: draft.trim()
    });
    setDraft("");
  }

  async function sendImages() {
    if (!activeUserId || pendingImages.length === 0) {
      return;
    }
    await sendMessage(setChat, {
      receiverId: activeUserId,
      type: "image",
      imageUrls: pendingImages
    });
    setPendingImages([]);
  }

  async function sendAudio() {
    if (!activeUserId) {
      return;
    }
    await sendMessage(setChat, {
      receiverId: activeUserId,
      type: "audio",
      audioUrl: "admin-recording",
      durationSeconds: recordingSeconds
    });
    setRecording(false);
    setRecordingSeconds(12);
  }

  return (
    <AdminShell active="chat">
      <h1 className="mb-5 text-2xl font-semibold text-black">Chat with Fellow4U</h1>
      <section className="grid min-h-[620px] rounded bg-white shadow-sm ring-1 ring-black/5">
        <div className="grid grid-rows-[1fr_auto] p-8">
          <div className="mx-auto flex w-full max-w-[860px] flex-col gap-4 overflow-y-auto px-2 py-2">
            <div className="text-center text-[10px] font-medium text-[#9AA1AA]">{formatChatDate(chat.messages[0]?.timestamp)}</div>
            {chat.messages.map((message) => (
              <ChatBubble message={message} onPreview={setPreviewImage} key={message.id} />
            ))}
          </div>

          {pendingImages.length > 0 ? (
            <div className="mx-auto mb-4 grid w-full max-w-[660px] grid-cols-3 gap-2 md:grid-cols-6">
              {pendingImages.map((url, index) => (
                <div className="relative" key={`${url}-${index}`}>
                  <img className="h-20 w-full rounded object-cover" src={url} alt="" />
                  <button className="absolute right-1 top-1 grid h-5 w-5 place-items-center rounded-full bg-black/45 text-white" type="button" onClick={() => setPendingImages((items) => items.filter((_, itemIndex) => itemIndex !== index))}>
                    <X size={12} />
                  </button>
                </div>
              ))}
            </div>
          ) : null}

          <div className="mx-auto flex w-full max-w-[760px] items-center gap-3">
            {recording ? (
              <>
                <button className="grid h-9 w-9 place-items-center rounded-full text-[#4B5563] hover:bg-page" type="button" onClick={() => setRecording(false)}>
                  <X size={16} />
                </button>
                <div className="grid h-14 flex-1 grid-cols-[1fr_auto_1fr] items-center rounded-full bg-[#FBFAFF] px-8">
                  <span />
                  <button className="grid h-10 w-10 place-items-center rounded-full bg-white text-brand shadow-sm ring-1 ring-brand/20" type="button" onClick={() => setRecordingSeconds((value) => value + 1)}>
                    <Mic size={18} />
                  </button>
                  <span className="text-center text-xs text-muted">{formatDuration(recordingSeconds)}</span>
                </div>
                <button className="grid h-9 w-9 place-items-center rounded-full bg-brand text-white shadow-soft" type="button" onClick={sendAudio}>
                  <Send size={16} />
                </button>
              </>
            ) : (
              <>
                <button className="grid h-8 w-8 place-items-center rounded-full text-[#4B5563] hover:bg-page" type="button" onClick={() => setRecording(true)} aria-label="Record voice">
                  <Mic size={15} />
                </button>
                <button className="grid h-8 w-8 place-items-center rounded-full text-[#4B5563] hover:bg-page" type="button" onClick={() => setPendingImages((items) => [...items, ...sampleImageUrls])} aria-label="Attach images">
                  <Image size={15} />
                </button>
                <label className="flex h-10 flex-1 items-center rounded-full bg-[#FBFAFF] px-4 text-xs text-muted">
                  <input className="w-full bg-transparent text-[#333] outline-none" value={draft} onChange={(event) => setDraft(event.target.value)} onKeyDown={(event) => {
                    if (event.key === "Enter") {
                      event.preventDefault();
                      sendText();
                    }
                  }} placeholder="Type message" />
                </label>
                <button className="grid h-9 w-9 place-items-center rounded-full bg-brand text-white shadow-soft" type="button" onClick={pendingImages.length > 0 ? sendImages : sendText}>
                  <Send size={16} />
                </button>
              </>
            )}
          </div>
        </div>
      </section>
      {previewImage ? <ImagePreview imageUrl={previewImage} onClose={() => setPreviewImage(null)} /> : null}
    </AdminShell>
  );
}

export function AdminBillingPage() {
  const [billing, setBilling] = useState<AdminBilling>(emptyBilling);
  const [tab, setTab] = useState<"history" | "payment">("history");
  const [editingPayment, setEditingPayment] = useState(false);
  const [editingPlans, setEditingPlans] = useState(false);
  const [selectedPlan, setSelectedPlan] = useState("");
  const [paymentForm, setPaymentForm] = useState({ cardHolderName: "", cardNumber: "", provider: "VISA" });

  useEffect(() => {
    refreshBilling(setBilling);
  }, []);

  useEffect(() => {
    setSelectedPlan(billing.subscription.planName || billing.plans.find((plan) => plan.selected)?.name || "Starter");
    setPaymentForm({
      cardHolderName: billing.paymentInfo.cardHolderName || "Phuong Nam Tour",
      cardNumber: billing.paymentInfo.cardNumberMasked || "",
      provider: billing.paymentInfo.provider || "VISA"
    });
  }, [billing]);

  async function savePayment() {
    const token = localStorage.getItem(tokenKey);
    if (!token) {
      return;
    }
    const nextBilling = await adminApi.updatePayment(token, paymentForm);
    setBilling(nextBilling);
    setEditingPayment(false);
  }

  async function savePlan() {
    const token = localStorage.getItem(tokenKey);
    if (!token) {
      return;
    }
    const nextBilling = await adminApi.updatePlan(token, selectedPlan);
    setBilling(nextBilling);
    setEditingPlans(false);
  }

  return (
    <AdminShell active="billing">
      <h1 className="mb-5 text-2xl font-semibold text-black">Billing History & Payment</h1>
      <section className="rounded bg-white shadow-sm ring-1 ring-black/5">
        <div className="flex border-b border-line px-6 pt-3 text-xs">
          <button className={`px-5 py-3 ${tab === "history" ? "border-b-2 border-brand text-brand" : "text-muted"}`} type="button" onClick={() => setTab("history")}>
            Billing History
          </button>
          <button className={`px-5 py-3 ${tab === "payment" ? "border-b-2 border-brand text-brand" : "text-muted"}`} type="button" onClick={() => setTab("payment")}>
            Payment Information
          </button>
        </div>

        {tab === "history" ? (
          <div className="p-6">
            <div className="mb-5 flex flex-wrap items-center gap-4">
              <select className="h-8 rounded border border-line bg-white px-3 text-xs text-muted">
                <option>20 page</option>
              </select>
              <label className="ml-auto flex h-8 min-w-[260px] items-center gap-2 rounded-full border border-line bg-white px-3 text-xs text-muted">
                <Search size={14} />
                <input className="w-full bg-transparent outline-none" placeholder="Search" />
              </label>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full min-w-[760px] border-collapse text-left text-xs">
                <thead>
                  <tr className="border-y border-line text-[#555]">
                    <th className="w-8 py-3"><input type="checkbox" /></th>
                    <th className="py-3">Bill ID</th>
                    <th className="py-3">Bill Name</th>
                    <th className="py-3">Date</th>
                    <th className="py-3">Amount</th>
                    <th className="py-3 text-right">Action</th>
                  </tr>
                </thead>
                <tbody>
                  {billing.invoices.map((invoice) => (
                    <tr className="border-b border-line last:border-b-0" key={`${invoice.billId}-${invoice.date}`}>
                      <td className="py-3"><input type="checkbox" /></td>
                      <td className="py-3 font-medium text-[#555]">{invoice.billId}</td>
                      <td className="py-3 text-[#333]">{invoice.billName}</td>
                      <td className="py-3 text-muted">{formatDate(invoice.date)}</td>
                      <td className="py-3 text-muted">${Number(invoice.amount || 0).toFixed(0)}</td>
                      <td className="py-3 text-right text-muted"><MoreHorizontal size={16} className="ml-auto" /></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <Pager />
          </div>
        ) : (
          <div>
            <section className="border-b border-line p-8">
              <div className="mb-6 flex items-center gap-2 text-sm font-bold text-[#333]">
                <CreditCard size={15} /> Payment Info
              </div>
              {editingPayment ? (
                <div className="mx-auto grid max-w-[360px] gap-4">
                  <AdminField label="Card Holder's Name" value={paymentForm.cardHolderName} onChange={(value) => setPaymentForm({ ...paymentForm, cardHolderName: value })} />
                  <AdminField label="Card Number" value={paymentForm.cardNumber} onChange={(value) => setPaymentForm({ ...paymentForm, cardNumber: value })} />
                  <div className="grid grid-cols-2 gap-5">
                    <AdminField label="Expiration Date" value="04/2030" onChange={() => undefined} />
                    <AdminField label="CVV" value="587" onChange={() => undefined} />
                  </div>
                  <div className="mt-3 flex justify-center gap-3">
                    <button className="h-8 min-w-24 rounded border border-brand px-5 text-xs font-bold text-brand" type="button" onClick={() => setEditingPayment(false)}>CANCEL</button>
                    <button className="h-8 min-w-24 rounded bg-brand px-5 text-xs font-bold text-white" type="button" onClick={savePayment}>SAVE</button>
                  </div>
                </div>
              ) : (
                <div className="mx-auto max-w-[360px]">
                  <span className="mb-2 block text-xs font-bold text-[#333]">Card Number</span>
                  <div className="mb-4 h-9 bg-[#f2f2f2] px-4 py-2 text-xs text-[#555]">{billing.paymentInfo.cardNumberMasked || "No card"}</div>
                  <button className="h-8 rounded bg-brand px-5 text-xs font-bold text-white" type="button" onClick={() => setEditingPayment(true)}>UPDATE PAYMENT INFO</button>
                </div>
              )}
            </section>

            <section className="p-8">
              <div className="mb-6 flex items-center gap-3">
                <div className="flex items-center gap-2 text-sm font-bold text-[#333]"><CreditCard size={15} /> Plans</div>
                <button className="ml-auto h-8 rounded bg-brand px-5 text-xs font-bold text-white" type="button" onClick={() => setEditingPlans(true)}>UPDATE PLANS</button>
              </div>
              {editingPlans ? (
                <p className="mx-auto mb-6 max-w-[680px] text-center text-xs leading-5 text-[#555]">
                  Your currently plan is {billing.subscription.planName} ${billing.subscription.yearlyPrice}/year and it was subscribed on {formatDate(billing.subscription.startedAt)}.
                  You can select another plan below and save it for the next billing period.
                </p>
              ) : null}
              <div className="mx-auto grid max-w-[820px] gap-5 md:grid-cols-3">
                {billing.plans.map((plan) => (
                  <PlanOptionCard plan={plan} selected={(editingPlans ? selectedPlan : billing.subscription.planName) === plan.name} onSelect={() => setSelectedPlan(plan.name)} editable={editingPlans} key={plan.name} />
                ))}
              </div>
              {editingPlans ? (
                <div className="mt-8 flex justify-center gap-3">
                  <button className="h-8 min-w-24 rounded border border-brand px-5 text-xs font-bold text-brand" type="button" onClick={() => setEditingPlans(false)}>CANCEL</button>
                  <button className="h-8 min-w-24 rounded bg-brand px-5 text-xs font-bold text-white" type="button" onClick={savePlan}>SAVE</button>
                </div>
              ) : null}
            </section>
          </div>
        )}
      </section>
    </AdminShell>
  );
}

function AdminShell({ active, children, narrow = false }: { active: AdminPage; children: React.ReactNode; narrow?: boolean }) {
  return (
    <main className="min-h-screen bg-page">
      <div className="min-h-screen bg-page">
        <header className="flex h-16 items-center bg-brand px-8 text-white">
          <button className="mr-auto" type="button" onClick={() => navigate("/admin/dashboard")} aria-label="Dashboard">
            <img className="w-24" src={logoWhite} alt="Fellow4U" />
          </button>
          <Bell size={15} />
          <button className="ml-8 inline-flex h-7 items-center gap-2 rounded-full bg-white/15 px-3 text-xs" type="button">
            English <ChevronDown size={12} />
          </button>
          <button className="ml-5 inline-flex items-center gap-2 text-xs" type="button">
            <span className="grid h-8 w-8 place-items-center rounded-full bg-white text-brand"><Globe2 size={16} /></span>
            Phuong Nam Tour <ChevronDown size={12} />
          </button>
        </header>

        <div className="grid min-h-[calc(100vh-6.5rem)] grid-cols-1 lg:grid-cols-[220px_1fr]">
          <aside className="bg-white px-5 py-8">
            <nav className="grid gap-5">
              <NavItem icon={Grid2X2} label="Dashboard" active={active === "dashboard"} onClick={() => navigate("/admin/dashboard")} />
              <NavItem icon={Globe2} label="Tours" active={active === "tours" || active === "tour-new" || active === "tour-edit"} onClick={() => navigate("/admin/tours")} />
              <NavItem icon={MessageSquare} label="Chat" active={active === "chat"} badge="2" onClick={() => navigate("/admin/chat")} />
              <NavItem icon={CreditCard} label="Billing History & Payment" active={active === "billing"} onClick={() => navigate("/admin/billing")} />
              <NavItem icon={Headphones} label="Support" />
            </nav>
          </aside>
          <section className={`p-6 md:p-8 ${narrow ? "max-w-[1040px]" : ""}`}>{children}</section>
        </div>
      </div>
    </main>
  );
}

function NavItem({ icon: Icon, label, active = false, badge, onClick }: { icon: LucideIcon; label: string; active?: boolean; badge?: string; onClick?: () => void }) {
  return (
    <button className={`relative flex items-center gap-3 text-left text-xs font-medium ${active ? "text-brand" : "text-[#777] hover:text-brand"}`} type="button" onClick={onClick}>
      {active ? <span className="absolute -left-5 h-6 w-1 bg-brand" /> : null}
      <Icon size={16} />
      <span className="mr-auto">{label}</span>
      {badge ? <span className="grid h-5 w-5 place-items-center rounded-full bg-coral text-[10px] font-bold text-white">{badge}</span> : null}
    </button>
  );
}

function ChatBubble({ message, onPreview }: { message: AdminChatMessage; onPreview: (url: string) => void }) {
  if (message.type === "image") {
    return (
      <div className={`flex ${message.mine ? "justify-end" : "justify-start"}`}>
        <div className="grid max-w-[520px] grid-cols-3 gap-2">
          {message.imageUrls.map((url) => (
            <button className="overflow-hidden rounded" type="button" onClick={() => onPreview(url)} key={`${message.id}-${url}`}>
              <img className="h-28 w-40 object-cover" src={url} alt="" />
            </button>
          ))}
        </div>
      </div>
    );
  }

  if (message.type === "audio") {
    return (
      <div className={`flex ${message.mine ? "justify-end" : "justify-start"}`}>
        <div className="w-full max-w-[360px] rounded bg-[#2F9BF0] px-4 py-4 text-white">
          <div className="flex items-center justify-center">
            <span className="grid h-10 w-10 place-items-center rounded-full border border-white/80">
              <Play size={18} />
            </span>
          </div>
          <div className="mt-4 grid grid-cols-[1fr_auto] items-center gap-3">
            <span className="h-1 rounded-full bg-white/80" />
            <span className="text-[10px]">{formatDuration(message.durationSeconds || 0)}</span>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className={`flex ${message.mine ? "justify-end" : "justify-start"}`}>
      <div className={`max-w-[430px] rounded px-4 py-2 text-xs leading-5 ${message.mine ? "bg-[#FBFAFF] text-[#333]" : "bg-brand text-white"}`}>
        {!message.mine ? (
          <div className="mb-1 flex items-center gap-2 text-[10px] text-white/80">
            <span className="grid h-5 w-5 place-items-center rounded-full bg-white text-brand">b</span>
            <span>{message.senderName || "Fellow4U"}</span>
            <span>{formatChatTime(message.timestamp)}</span>
          </div>
        ) : null}
        {message.text}
      </div>
    </div>
  );
}

function ImagePreview({ imageUrl, onClose }: { imageUrl: string; onClose: () => void }) {
  return (
    <div className="fixed inset-0 z-50 bg-black/70 px-10 py-12">
      <button className="absolute right-12 top-12 grid h-8 w-8 place-items-center rounded-full bg-white/20 text-white" type="button" onClick={onClose} aria-label="Close image">
        <X size={18} />
      </button>
      <img className="mx-auto h-full max-h-[calc(100vh-6rem)] w-full max-w-[1120px] object-contain" src={imageUrl} alt="" />
    </div>
  );
}

function PlanOptionCard({ plan, selected, editable, onSelect }: { plan: AdminBilling["plans"][number]; selected: boolean; editable: boolean; onSelect: () => void }) {
  return (
    <button className="relative overflow-hidden rounded border border-line bg-white text-left shadow-sm" type="button" onClick={editable ? onSelect : undefined}>
      <span className={`absolute right-2 top-2 grid h-6 w-6 place-items-center rounded-full text-xs text-white ${selected ? "bg-[#7CB342]" : "bg-[#C9CED6]"}`}>✓</span>
      <header className="bg-brand px-4 py-4 text-center text-white">
        <h3 className="text-sm font-medium">{plan.name}</h3>
        <p className="mt-1 text-sm">$ <strong className="text-2xl font-light">{Number(plan.yearlyPrice).toFixed(0)}</strong> /year</p>
      </header>
      <div className="grid gap-3 p-4 text-[11px] leading-4 text-[#666]">
        <p>{plan.description}</p>
        <p>Lorem Ipsum has been the industry's standard dummy text ever since.</p>
        <p>Since the 1500s, when an unknown printer took a galley of type.</p>
        <p>It has survived and only few centuries.</p>
      </div>
    </button>
  );
}

function Pager() {
  return (
    <div className="mt-5 flex justify-end gap-2 text-xs">
      {[1, 2, 3].map((page) => (
        <button className={`grid h-7 w-7 place-items-center rounded ${page === 1 ? "bg-brand text-white" : "bg-[#333] text-white"}`} type="button" key={page}>
          {page}
        </button>
      ))}
    </div>
  );
}

async function refreshBilling(setBilling: (billing: AdminBilling) => void) {
  const token = localStorage.getItem(tokenKey);
  if (!token) {
    setBilling(emptyBilling);
    return;
  }
  adminApi.getBilling(token).then(setBilling).catch(() => setBilling(emptyBilling));
}

async function refreshChat(setChat: (chat: AdminChat) => void, userId?: string) {
  const token = localStorage.getItem(tokenKey);
  if (!token) {
    setChat(emptyChat);
    return;
  }

  adminApi.getChat(token, userId).then(setChat).catch(() => setChat(emptyChat));
}

async function sendMessage(setChat: React.Dispatch<React.SetStateAction<AdminChat>>, payload: Parameters<typeof adminApi.sendChatMessage>[1]) {
  const token = localStorage.getItem(tokenKey);
  if (!token) {
    return;
  }

  const message = await adminApi.sendChatMessage(token, payload);
  setChat((current) => ({
    ...current,
    messages: [...current.messages, message]
  }));
}

function StatTile({ icon: Icon, label, value, tone }: { icon: LucideIcon; label: string; value: string; tone: "teal" | "amber" }) {
  const text = tone === "teal" ? "text-brand" : "text-amber";
  return (
    <article className="grid h-28 grid-cols-[90px_1px_1fr] items-center rounded-md bg-white p-6 shadow-sm ring-1 ring-black/5">
      <Icon className={text} size={48} strokeWidth={1.8} />
      <span className={`h-16 ${tone === "teal" ? "bg-brand" : "bg-amber"}`} />
      <div className="pl-7">
        <span className={`block text-xs ${text}`}>{label}</span>
        <strong className={`mt-1 block text-4xl font-light ${text}`}>{value}</strong>
      </div>
    </article>
  );
}

function LineChart({ values, labels }: { values: number[]; labels: string[] }) {
  const max = Math.max(500, ...values);
  const points = values.map((value, index) => {
    const x = 40 + index * (720 / Math.max(1, labels.length - 1));
    const y = 240 - (value / max) * 210;
    return `${x},${y}`;
  });

  return (
    <svg className="h-[300px] w-full" viewBox="0 0 820 300" role="img" aria-label="Booked tours chart">
      {[0, 100, 200, 300, 400, 500].map((value) => {
        const y = 240 - (value / 500) * 210;
        return (
          <g key={value}>
            <line x1="40" x2="780" y1={y} y2={y} stroke="#E6E9EF" />
            <text x="10" y={y + 4} fill="#9AA1AA" fontSize="10">{value}</text>
          </g>
        );
      })}
      <polyline fill="none" stroke="#00CEA6" strokeWidth="2" points={points.join(" ")} />
      {points.map((point) => {
        const [x, y] = point.split(",");
        return <circle cx={x} cy={y} fill="#00CEA6" r="4" key={point} />;
      })}
      {labels.map((label, index) => {
        const x = 40 + index * (720 / Math.max(1, labels.length - 1));
        return <text x={x} y="278" fill="#8B929C" fontSize="10" textAnchor="middle" key={label}>{label}</text>;
      })}
    </svg>
  );
}

function EmptyTours() {
  return (
    <section className="grid min-h-[430px] place-items-center rounded-md bg-white p-8 text-center shadow-sm ring-1 ring-black/5">
      <div>
        <Globe2 className="mx-auto text-[#D9DDE3]" size={90} strokeWidth={1.5} />
        <p className="mt-6 max-w-[360px] text-xs leading-5 text-[#666]">You do not have any tours yet. Now you add your tours here so Travelers can find the tours.</p>
        <button className="mt-9 h-10 rounded bg-brand px-14 text-xs font-bold text-white shadow-soft" type="button" onClick={() => navigate("/admin/tours/new")}>
          ADD TOUR
        </button>
      </div>
    </section>
  );
}

function SectionTitle({ children }: { children: React.ReactNode }) {
  return <h2 className="text-sm font-bold text-brand">{children}</h2>;
}

function AdminField({ label, value, onChange, placeholder, type = "text", className = "" }: { label: string; value: string | number; onChange: (value: string) => void; placeholder?: string; type?: string; className?: string }) {
  return (
    <label className={`block ${className}`}>
      <span className="mb-1 block text-xs font-bold text-[#333]">{label}</span>
      <input className="h-8 w-full border-0 border-b border-line bg-transparent px-0 text-xs text-[#333] outline-none focus:border-brand" type={type} value={value} onChange={(event) => onChange(event.target.value)} placeholder={placeholder} />
    </label>
  );
}

function AdminSelect({ label, value, onChange, options }: { label: string; value: string; onChange: (value: string) => void; options: string[] }) {
  return (
    <label className="block">
      <span className="mb-1 block text-xs font-bold text-[#333]">{label}</span>
      <select className="h-8 w-full border-0 border-b border-line bg-transparent px-0 text-xs text-[#333] outline-none focus:border-brand" value={value} onChange={(event) => onChange(event.target.value)}>
        {options.map((option) => <option key={option}>{option}</option>)}
      </select>
    </label>
  );
}

function UploadBox({ compact = false }: { compact?: boolean }) {
  return (
    <button className={`${compact ? "h-20 w-28" : "h-28 w-40"} grid place-items-center rounded border border-dashed border-brand bg-brand/5 text-brand`} type="button">
      <span className="grid justify-items-center gap-1 text-[10px] font-bold">
        <Upload size={16} />
        upload Photo/Video
      </span>
    </button>
  );
}

function SocialContact() {
  return (
    <div>
      <span className="text-xs font-bold text-[#333]">Social Contact <span className="text-[#2F80ED]">(Optional)</span></span>
      <div className="mt-2 grid gap-2">
        {["Facebook", "Kakao Talk", "Line", "Twitter"].map((label) => (
          <input className="h-8 border-0 border-b border-line bg-transparent text-xs outline-none focus:border-brand" placeholder={label} key={label} />
        ))}
      </div>
    </div>
  );
}

function PriceRow({ label, value, onChange, suffix = "USD" }: { label: string; value: string; onChange: (value: string) => void; suffix?: string }) {
  return (
    <label className="grid grid-cols-[1fr_100px_54px] items-center border-b border-line last:border-b-0">
      <span className="px-3 py-3 text-[#333]">{label}</span>
      <input className="h-full border-0 border-l border-line px-3 text-xs outline-none" value={value} onChange={(event) => onChange(event.target.value)} />
      <span className="border-l border-line px-3 py-3 text-muted">{suffix}</span>
    </label>
  );
}

function Toggle({ enabled }: { enabled: boolean }) {
  return <span className={`inline-flex h-4 w-8 items-center rounded-full p-0.5 ${enabled ? "bg-brand" : "bg-[#C9CED6]"}`}><span className={`h-3 w-3 rounded-full bg-white ${enabled ? "ml-auto" : ""}`} /></span>;
}

async function refreshTours(setTours: (tours: AdminTour[]) => void) {
  const token = localStorage.getItem(tokenKey);
  if (!token) {
    setTours([]);
    return;
  }

  adminApi.getTours(token).then(setTours).catch(() => setTours([]));
}

function toPayload(tour: AdminTour): AdminTourPayload {
  return {
    title: tour.title,
    description: tour.description || "",
    imageUrl: tour.imageUrl,
    price: Number(tour.price || 0),
    location: tour.location || "",
    duration: tour.duration || "",
    startDate: tour.startDate || "",
    rating: tour.rating || 4.5,
    reviewCount: tour.reviewCount || 0,
    category: tour.category || "REGULAR"
  };
}

function normalizePayload(payload: AdminTourPayload): AdminTourPayload {
  return {
    ...payload,
    price: Number(payload.price || 0),
    rating: Number(payload.rating || 4.5),
    reviewCount: Number(payload.reviewCount || 0),
    startDate: payload.startDate || undefined
  };
}

function navigate(path: string) {
  window.history.pushState({}, "", path);
  window.dispatchEvent(new PopStateEvent("popstate"));
}

function cityOf(location?: string) {
  return (location || "").split(",")[0]?.trim() || "";
}

function countryOf(location?: string) {
  return (location || "").split(",").slice(1).join(",").trim() || "";
}

function joinLocation(city: string, country: string) {
  return [city, country].filter(Boolean).join(", ");
}

function shortId(id: string) {
  return id.slice(0, 8).toUpperCase();
}

function formatDate(date?: string) {
  if (!date) {
    return "-";
  }
  return new Intl.DateTimeFormat("en", { month: "2-digit", day: "2-digit", year: "numeric" }).format(new Date(date));
}

function formatChatDate(date?: string) {
  if (!date) {
    return "";
  }
  return new Intl.DateTimeFormat("en", { month: "short", day: "2-digit", year: "numeric" }).format(new Date(date));
}

function formatChatTime(date?: string) {
  if (!date) {
    return "";
  }
  return new Intl.DateTimeFormat("en", { hour: "2-digit", minute: "2-digit" }).format(new Date(date));
}

function formatDuration(seconds: number) {
  const minutes = Math.floor(seconds / 60);
  const remainder = seconds % 60;
  return `${minutes}:${String(remainder).padStart(2, "0")}`;
}

function metricValue(dashboard: AdminDashboard, label: string) {
  return dashboard.metrics.find((metric) => metric.label === label)?.value ?? "0";
}
