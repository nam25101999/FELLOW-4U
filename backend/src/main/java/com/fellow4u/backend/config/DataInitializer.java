package com.fellow4u.backend.config;

import com.fellow4u.backend.entity.*;
import com.fellow4u.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

        private final TourRepository tourRepository;
        private final UserRepository userRepository;
        private final ExperienceRepository experienceRepository;
        private final TravelNewsRepository travelNewsRepository;
        private final AttractionRepository attractionRepository;
        private final BookingRepository bookingRepository;
        private final UserPhotoRepository userPhotoRepository;
        private final UserJourneyRepository userJourneyRepository;
        private final PaymentMethodRepository paymentMethodRepository;
        private final UserFeedbackRepository userFeedbackRepository;
        private final PasswordResetTokenRepository passwordResetTokenRepository;
        private final ChatMessageRepository chatMessageRepository;
        private final NotificationRepository notificationRepository;
        private final AdminSubscriptionRepository adminSubscriptionRepository;
        private final PasswordEncoder passwordEncoder;

        @Override
        @Transactional
        public void run(String... args) throws Exception {
                boolean hasNoUsers = userRepository.count() == 0;
                ensureAdminUser();

                // Only seed user/tour data if the database is empty
                if (hasNoUsers) {
                        seedInitialData();
                } else if (!userRepository.existsByEmail("1")) {
                        userRepository.save(User.builder()
                                        .email("1")
                                        .password(passwordEncoder.encode("1"))
                                        .firstName("Nam")
                                        .lastName("Nguyen")
                                        .role("TRAVELER")
                                        .build());
                }

                // Seed Sample Chat Messages if none exist
                if (chatMessageRepository.count() == 0) {
                        seedChatData();
                }

                // Seed Sample Notifications if none exist
                if (notificationRepository.count() == 0) {
                        seedNotificationData();
                } else {
                        User user1 = userRepository.findByEmail("1").orElse(null);
                        if (user1 != null && notificationRepository.findByUserOrderByTimestampDesc(user1).isEmpty()) {
                                seedNotificationData();
                        }
                }

                ensureDemoData();

                // Always force update all images for demo to ensure local paths are used
                forceUpdateAllImages();
        }

        private void ensureAdminUser() {
                if (!userRepository.existsByEmail("admin@fellow4u.com")) {
                        userRepository.save(User.builder()
                                        .email("admin@fellow4u.com")
                                        .password(passwordEncoder.encode("admin123"))
                                        .firstName("Admin")
                                        .lastName("Fellow4U")
                                        .role("ADMIN")
                                        .location("Da Nang, Vietnam")
                                        .avatarUrl("https://ui-avatars.com/api/?name=Fellow4U+Admin&background=00CEA6&color=ffffff")
                                        .build());
                }
        }

        private void seedInitialData() {
                // 1. Nạp 20 Hướng dẫn viên (Guides)
                String[] guideNames = { "Tuan Tran", "Linh Hana", "Khai Ho", "Emmy", "Ngoc Diep", "Hoang Nam",
                                "Minh Anh", "Phuong Thao", "Gia Bao", "Thuy Linh" };
                String[] locations = { "Danang, Vietnam", "Hanoi, Vietnam", "Saigon, Vietnam", "Hoi An, Vietnam",
                                "Phu Quoc, Vietnam" };

                // Thêm tài khoản test cho user
                User testUser = userRepository.findByEmail("1").orElseGet(() -> 
                        userRepository.save(User.builder()
                                .email("1")
                                .password(passwordEncoder.encode("1"))
                                .firstName("Nam")
                                .lastName("Nguyen")
                                .role("TRAVELER")
                                .location("Hanoi, Vietnam")
                                .avatarUrl("https://ui-avatars.com/api/?name=Nam+Nguyen&background=random")
                                .build())
                );

                // Nạp Photos cho testUser
                String[] samplePhotos = {
                                "http://127.0.0.1:8080/uploads/location/images.jpg",
                                "http://127.0.0.1:8080/uploads/location/images_1.jpg",
                                "http://127.0.0.1:8080/uploads/location/tai_xuong.jpg",
                                "http://127.0.0.1:8080/uploads/location/tai_xuong_1.jpg",
                                "http://127.0.0.1:8080/uploads/location/tai_xuong_2.jpg"
                };
                for (String url : samplePhotos) {
                        userPhotoRepository.save(UserPhoto.builder().imageUrl(url).user(testUser)
                                        .createdAt(java.time.LocalDateTime.now()).build());
                }

                // Nạp Journeys cho testUser
                userJourneyRepository.save(UserJourney.builder()
                                .title("A memory in Danang")
                                .location("Danang, Vietnam")
                                .date("Jan 20, 2020")
                                .likeCount(234)
                                .user(testUser)
                                .imageUrls(java.util.List.of(
                                                "http://127.0.0.1:8080/uploads/location/images.jpg",
                                                "http://127.0.0.1:8080/uploads/location/tai_xuong_4.jpg"))
                                .build());

                // Create Seed Cards & Wallets
                paymentMethodRepository.save(PaymentMethod.builder()
                                .name("Visa **** 1234")
                                .identifier("**** 1234")
                                .provider("VISA")
                                .type("CARD")
                                .user(testUser)
                                .build());

                paymentMethodRepository.save(PaymentMethod.builder()
                                .name("Mastercard **** 5678")
                                .identifier("**** 5678")
                                .provider("MASTERCARD")
                                .type("CARD")
                                .user(testUser)
                                .build());

                paymentMethodRepository.save(PaymentMethod.builder()
                                .name("MoMo Wallet")
                                .identifier("0987654321")
                                .provider("MOMO")
                                .type("WALLET")
                                .user(testUser)
                                .build());

                paymentMethodRepository.save(PaymentMethod.builder()
                                .name("ZaloPay Wallet")
                                .identifier("0987654321")
                                .provider("ZALOPAY")
                                .type("WALLET")
                                .user(testUser)
                                .build());

                userJourneyRepository.save(UserJourney.builder()
                                .title("Sapa in spring")
                                .location("Sapa, Vietnam")
                                .date("Mar 15, 2020")
                                .likeCount(128)
                                .user(testUser)
                                .imageUrls(java.util.List.of(
                                                "http://127.0.0.1:8080/uploads/location/tai_xuong_5.jpg"))
                                .build());

                for (int i = 0; i < 20; i++) {
                        User guide = User.builder()
                                        .email("guide" + i + "@fellow4u.com")
                                        .password(passwordEncoder.encode("password"))
                                        .firstName(guideNames[i % guideNames.length].split(" ")[0])
                                        .lastName(guideNames[i % guideNames.length].split(" ").length > 1
                                                        ? guideNames[i % guideNames.length].split(" ")[1]
                                                        : "")
                                        .role("GUIDE")
                                        .location(locations[i % locations.length])
                                        .avatarUrl("https://ui-avatars.com/api/?name="
                                                        + guideNames[i % guideNames.length].replace(" ", "+")
                                                        + "&background=random&size=200")
                                        .bio("Expert guide with 5+ years experience in "
                                                        + locations[i % locations.length])
                                        .rating(4.0 + (i % 10) * 0.1)
                                        .reviewCount(50 + i * 5)
                                        .build();
                        userRepository.save(guide);
                }

                // 2. Nạp 20 Tours
                String[] tourTitles = {
                                "Da Nang - Ba Na - Hoi An", "Hanoi City Discovery", "Saigon Street Food",
                                "Ha Long Bay Cruise",
                                "Nha Trang Island Hop", "Phu Quoc Sunset", "Sapa Trekking Adventure",
                                "Hue Royal Heritage",
                                "Mekong Delta Boat", "Mui Ne Sand Dunes", "Da Lat Romantic Tour",
                                "Cuchi Tunnels History"
                };
                String[] tourImages = {
                                "http://127.0.0.1:8080/uploads/location/images.jpg", // Da Nang
                                "http://127.0.0.1:8080/uploads/location/tai_xuong_4.jpg", // Ha Long
                                "http://127.0.0.1:8080/uploads/location/tai_xuong_3.jpg", // Saigon
                                "http://127.0.0.1:8080/uploads/location/tai_xuong_1.jpg", // Hoi An
                                "http://127.0.0.1:8080/uploads/location/images.jpg", // Travel
                                "http://127.0.0.1:8080/uploads/location/images_1.jpg" // Beach
                };

                for (int i = 0; i < 20; i++) {
                        Tour.TourCategory cat = (i < 10) ? Tour.TourCategory.TOP_JOURNEY : Tour.TourCategory.FEATURED;
                        Tour tour = Tour.builder()
                                        .title(tourTitles[i % tourTitles.length] + (i > 11 ? " #" + i : ""))
                                        .imageUrl(tourImages[i % tourImages.length] + "?w=1000&q=80")
                                        .price(BigDecimal.valueOf(100 + (i * 25)))
                                        .category(cat)
                                        .startDate(LocalDate.now().plusWeeks(1 + i))
                                        .duration((2 + (i % 3)) + " days")
                                        .rating(4.5 + (i % 2) * 0.5)
                                        .reviewCount(50 + i * 12)
                                        .build();
                        tourRepository.save(tour);
                }

                // 3. Nạp 20 Trải nghiệm (Experiences)
                for (int i = 0; i < 20; i++) {
                        Experience exp = Experience.builder()
                                        .title("Experience " + i)
                                        .imageUrl(tourImages[(i + 2) % tourImages.length] + "?w=600&q=80")
                                        .authorName(guideNames[i % guideNames.length])
                                        .authorImageUrl("https://ui-avatars.com/api/?name="
                                                        + guideNames[i % guideNames.length].replace(" ", "+"))
                                        .build();
                        experienceRepository.save(exp);
                }

                // 4. Nạp 3 Tin tức (Travel News)
                for (int i = 0; i < 3; i++) {
                        TravelNews news = TravelNews.builder()
                                        .title("Vietnam reopens borders for tourism - Update " + i)
                                        .imageUrl("http://127.0.0.1:8080/uploads/location/tai_xuong_7.jpg")
                                        .publishedDate(LocalDate.now().minusWeeks(i))
                                        .build();
                        travelNewsRepository.save(news);
                }

                // 5. Nạp 15 Địa điểm tham quan (Attractions)
                String[] attractionNames = { "Dragon Bridge", "My Khe Beach", "Cham Museum", "Marble Mountains",
                                "Ba Na Hills", "Son Tra Peninsula", "Hoi An Ancient Town", "An Bang Beach" };
                for (int i = 0; i < 15; i++) {
                        Attraction att = Attraction.builder()
                                        .name(attractionNames[i % attractionNames.length])
                                        .city("Danang")
                                        .imageUrl(tourImages[i % tourImages.length] + "?w=400&q=80")
                                        .build();
                        attractionRepository.save(att);
                }

                // 6. Nạp Bookings mẫu
                List<Attraction> allAtts = attractionRepository.findAll();
                Booking b1 = Booking.builder()
                                .tripTitle("Dragon Bridge Trip")
                                .location("Danang, Vietnam")
                                .date(LocalDate.now())
                                .timeSlot("13:00 - 15:00")
                                .guideName("Tuan Tran")
                                .guideAvatarUrl("https://ui-avatars.com/api/?name=Tuan+Tran")
                                .travelers(2)
                                .totalFee(BigDecimal.valueOf(20.00))
                                .status("CURRENT")
                                .paymentStatus("PAID_100")
                                .attractions(allAtts.subList(0, 3))
                                .user(testUser)
                                .build();
                bookingRepository.save(b1);

                Booking b2 = Booking.builder()
                                .tripTitle("Ho Guom Trip")
                                .location("Hanoi, Vietnam")
                                .date(LocalDate.now().plusDays(2))
                                .timeSlot("8:00 - 10:00")
                                .guideName("Emmy")
                                .guideAvatarUrl("https://ui-avatars.com/api/?name=Emmy")
                                .travelers(2)
                                .totalFee(BigDecimal.valueOf(20.00))
                                .status("NEXT")
                                .paymentStatus("UNPAID")
                                .attractions(allAtts.subList(3, 5))
                                .user(testUser)
                                .build();
                bookingRepository.save(b2);

                Booking b3 = Booking.builder()
                                .tripTitle("Quoc Tu Giam Temple")
                                .location("Hanoi, Vietnam")
                                .date(LocalDate.now().minusWeeks(2))
                                .timeSlot("9:00 - 11:00")
                                .guideName("Ngoc Diep")
                                .guideAvatarUrl("https://ui-avatars.com/api/?name=Ngoc+Diep")
                                .travelers(1)
                                .totalFee(BigDecimal.valueOf(15.00))
                                .status("PAST")
                                .paymentStatus("PAID_100")
                                .attractions(allAtts.subList(1, 2))
                                .user(testUser)
                                .build();
                bookingRepository.save(b3);
        }

        private void seedChatData() {
                User testUser = userRepository.findByEmail("1").orElse(null);
                if (testUser == null)
                        return;

                List<User> allGuides = userRepository.findAll().stream()
                                .filter(u -> "GUIDE".equals(u.getRole()))
                                .limit(5)
                                .toList();

                if (!allGuides.isEmpty()) {
                        User g1 = allGuides.get(0);
                        User g2 = allGuides.get(1);
                        User g3 = allGuides.get(2);

                        chatMessageRepository.save(ChatMessage.builder()
                                        .sender(g1).receiver(testUser).content("It's a beautiful place")
                                        .timestamp(java.time.LocalDateTime.now().minusHours(2)).build());
                        chatMessageRepository.save(ChatMessage.builder()
                                        .sender(testUser).receiver(g1).content("I agree!")
                                        .timestamp(java.time.LocalDateTime.now().minusHours(1)).build());

                        chatMessageRepository.save(ChatMessage.builder()
                                        .sender(g2).receiver(testUser).content("We can start at 8am")
                                        .timestamp(java.time.LocalDateTime.now().minusMinutes(30)).isRead(false)
                                        .build());

                        chatMessageRepository.save(ChatMessage.builder()
                                        .sender(g3).receiver(testUser).content("See you tomorrow")
                                        .timestamp(java.time.LocalDateTime.now().minusHours(5)).build());
                }
        }

        private void seedNotificationData() {
                User testUser = userRepository.findByEmail("1").orElse(null);
                if (testUser == null)
                        return;

                notificationRepository.save(UserNotification.builder()
                                .user(testUser)
                                .title("Trip Accepted")
                                .message("Tuan Tran accepted your request for the trip in Danang, Vietnam on Jan 20, 2020")
                                .avatarUrl("https://ui-avatars.com/api/?name=Tuan+Tran")
                                .type("TRIP_ACCEPTED")
                                .timestamp(java.time.LocalDateTime.of(2020, 1, 16, 10, 0))
                                .build());

                notificationRepository.save(UserNotification.builder()
                                .user(testUser)
                                .title("Offer Received")
                                .message("Emmy sent you an offer for the trip in Ho Chi Minh, Vietnam on Feb 12, 2020")
                                .avatarUrl("https://ui-avatars.com/api/?name=Emmy")
                                .type("OFFER_RECEIVED")
                                .timestamp(java.time.LocalDateTime.of(2020, 1, 16, 11, 30))
                                .build());

                notificationRepository.save(UserNotification.builder()
                                .user(testUser)
                                .title("Trip Finished")
                                .message("Thanks! Your trip in Danang, Vietnam on Jan 20, 2020 has been finished. Please leave a review for the guide Tuan Tran.")
                                .avatarUrl(null)
                                .type("TRIP_FINISHED")
                                .actionType("LEAVE_REVIEW")
                                .timestamp(java.time.LocalDateTime.of(2020, 1, 24, 15, 0))
                                .build());
        }

        private void forceUpdateTourImages() {
                String[] tourTitles = {
                                "Da Nang - Ba Na - Hoi An", "Hanoi City Discovery", "Saigon Street Food",
                                "Ha Long Bay Cruise",
                                "Nha Trang Island Hop", "Phu Quoc Sunset", "Sapa Trekking Adventure",
                                "Hue Royal Heritage",
                                "Mekong Delta Boat", "Mui Ne Sand Dunes", "Da Lat Romantic Tour",
                                "Cuchi Tunnels History"
                };
                String[] tourImages = {
                                "http://127.0.0.1:8080/uploads/location/images.jpg", // Da Nang
                                "http://127.0.0.1:8080/uploads/location/tai_xuong_4.jpg", // Ha Long
                                "http://127.0.0.1:8080/uploads/location/tai_xuong_3.jpg", // Saigon
                                "http://127.0.0.1:8080/uploads/location/tai_xuong_1.jpg", // Hoi An
                                "http://127.0.0.1:8080/uploads/location/images.jpg", // Travel
                                "http://127.0.0.1:8080/uploads/location/images_1.jpg" // Beach
                };

                tourRepository.findAll().forEach(tour -> {
                        for (int i = 0; i < tourTitles.length; i++) {
                                if (tour.getTitle().contains(tourTitles[i])) {
                                        String newUrl = tourImages[i % tourImages.length] + "?w=1000&q=80";
                                        if (tour.getImageUrl() == null || tour.getImageUrl().contains("unsplash.com") || tour.getImageUrl().contains("photo-")) {
                                                tour.setImageUrl(newUrl);
                                                tourRepository.save(tour);
                                        }
                                        break;
                                }
                        }
                });
        }

        private void forceUpdateAttractionImages() {
                attractionRepository.findAll().forEach(attr -> {
                        if (attr.getImageUrl() == null || attr.getImageUrl().contains("unsplash.com") || attr.getImageUrl().contains("tải xuống")) {
                                String name = attr.getName().toLowerCase();
                                String newUrl = "http://127.0.0.1:8080/uploads/location/images.jpg";
                                if (name.contains("bridge")) newUrl = "http://127.0.0.1:8080/uploads/location/images.jpg";
                                if (name.contains("beach")) newUrl = "http://127.0.0.1:8080/uploads/location/images_1.jpg";
                                if (name.contains("lake")) newUrl = "http://127.0.0.1:8080/uploads/location/tai_xuong.jpg";
                                if (name.contains("ancient town")) newUrl = "http://127.0.0.1:8080/uploads/location/tai_xuong_1.jpg";
                                if (name.contains("imperial")) newUrl = "http://127.0.0.1:8080/uploads/location/tai_xuong_2.jpg";
                                if (name.contains("market")) newUrl = "http://127.0.0.1:8080/uploads/location/tai_xuong_3.jpg";
                                if (name.contains("bay")) newUrl = "http://127.0.0.1:8080/uploads/location/tai_xuong_4.jpg";
                                if (name.contains("rice")) newUrl = "http://127.0.0.1:8080/uploads/location/tai_xuong_5.jpg";
                                
                                attr.setImageUrl(newUrl);
                                attractionRepository.save(attr);
                        }
                });
        }

        private void forceUpdateExperienceImages() {
                experienceRepository.findAll().forEach(exp -> {
                        if (exp.getImageUrl() == null || exp.getImageUrl().contains("unsplash.com")) {
                                int i = exp.getTitle().length(); // dummy index
                                String[] tourImages = {
                                        "http://127.0.0.1:8080/uploads/location/images.jpg",
                                        "http://127.0.0.1:8080/uploads/location/tai_xuong_4.jpg",
                                        "http://127.0.0.1:8080/uploads/location/tai_xuong_3.jpg",
                                        "http://127.0.0.1:8080/uploads/location/tai_xuong_1.jpg",
                                        "http://127.0.0.1:8080/uploads/location/images.jpg",
                                        "http://127.0.0.1:8080/uploads/location/images_1.jpg"
                                };
                                exp.setImageUrl(tourImages[i % tourImages.length]);
                                experienceRepository.save(exp);
                        }
                });
        }

        private void ensureDemoData() {
                User traveler = ensureDemoTraveler();
                ensureDemoGuides();
                ensureDemoAttractions();
                ensureDemoTours();
                ensureDemoBookings(traveler);
                ensureDemoWishlist(traveler);
                ensureDemoAdminChat(traveler);
                ensureDemoAdminBilling();
        }

        private void forceUpdateAllImages() {
                forceUpdateTourImages();
                forceUpdateAttractionImages();
                forceUpdateExperienceImages();
                forceUpdateTravelNewsImages();
                forceUpdateUserPhotos();
                forceUpdateUserJourneys();
                forceUpdateUserAvatars();
        }

        private void forceUpdateTravelNewsImages() {
                travelNewsRepository.findAll().forEach(news -> {
                        if (news.getImageUrl() == null || news.getImageUrl().contains("unsplash.com") || news.getImageUrl().contains("tải xuống")) {
                                news.setImageUrl("http://127.0.0.1:8080/uploads/location/tai_xuong_7.jpg");
                                travelNewsRepository.save(news);
                        }
                });
        }

        private void forceUpdateUserPhotos() {
                userPhotoRepository.findAll().forEach(photo -> {
                        if (photo.getImageUrl() == null || photo.getImageUrl().contains("unsplash.com") || photo.getImageUrl().contains("tải xuống")) {
                                String[] pool = {
                                        "http://127.0.0.1:8080/uploads/location/images.jpg",
                                        "http://127.0.0.1:8080/uploads/location/images_1.jpg",
                                        "http://127.0.0.1:8080/uploads/location/tai_xuong.jpg",
                                        "http://127.0.0.1:8080/uploads/location/tai_xuong_1.jpg"
                                };
                                photo.setImageUrl(pool[(photo.getId().hashCode() & Integer.MAX_VALUE) % pool.length]);
                                userPhotoRepository.save(photo);
                        }
                });
        }

        private void forceUpdateUserJourneys() {
                userJourneyRepository.findAll().forEach(journey -> {
                        if (journey.getImageUrls() != null) {
                                boolean needsUpdate = journey.getImageUrls().stream()
                                        .anyMatch(url -> url.contains("unsplash.com") || url.contains("tải xuống"));
                                if (needsUpdate) {
                                        journey.setImageUrls(List.of(
                                                "http://127.0.0.1:8080/uploads/location/images.jpg",
                                                "http://127.0.0.1:8080/uploads/location/tai_xuong_4.jpg"
                                        ));
                                        userJourneyRepository.save(journey);
                                }
                        }
                });
        }

        private void forceUpdateUserAvatars() {
                userRepository.findAll().forEach(user -> {
                        if (user.getAvatarUrl() != null && (user.getAvatarUrl().contains("unsplash.com") || user.getAvatarUrl().contains("pravatar"))) {
                                String displayName = (user.getFirstName() != null ? user.getFirstName() : "") + 
                                                   (user.getLastName() != null ? "+" + user.getLastName() : "");
                                if (displayName.isEmpty()) displayName = user.getEmail();
                                user.setAvatarUrl("https://ui-avatars.com/api/?name=" + displayName.replace(" ", "+") + "&background=random&size=200");
                                userRepository.save(user);
                        }
                });
        }

        private User ensureDemoTraveler() {
                return userRepository.findByEmail("1")
                                .orElseGet(() -> userRepository.save(User.builder()
                                                .email("1")
                                                .password(passwordEncoder.encode("1"))
                                                .firstName("Nam")
                                                .lastName("Nguyen")
                                                .role("TRAVELER")
                                                .location("Hanoi, Vietnam")
                                                .avatarUrl("https://ui-avatars.com/api/?name=Nam+Nguyen&background=random")
                                                .build()));
        }

        private void ensureDemoGuides() {
                // Format: { email, firstName, lastName, location, bio, rating }
                Object[][] guides = {
                        // ── Da Nang (20 guides) ──
                        { "guide.tuan.tran@fellow4u.com", "Tuan", "Tran", "Da Nang, Vietnam", "Expert on Da Nang beaches and Dragon Bridge light shows.", 4.9 },
                        { "guide.minh.le@fellow4u.com", "Minh", "Le", "Da Nang, Vietnam", "Specializes in Ba Na Hills and Golden Bridge tours.", 4.8 },
                        { "guide.thu.nguyen@fellow4u.com", "Thu", "Nguyen", "Da Nang, Vietnam", "Food tour specialist - best banh mi and mi quang spots.", 4.7 },
                        { "guide.hieu.pham@fellow4u.com", "Hieu", "Pham", "Da Nang, Vietnam", "Motorbike adventure guide through Hai Van Pass.", 4.9 },
                        { "guide.lan.vo@fellow4u.com", "Lan", "Vo", "Da Nang, Vietnam", "Cultural guide at Cham Museum and Marble Mountains.", 4.6 },
                        { "guide.duc.bui@fellow4u.com", "Duc", "Bui", "Da Nang, Vietnam", "Sunset boat tour guide along Han River.", 4.8 },
                        { "guide.mai.dang@fellow4u.com", "Mai", "Dang", "Da Nang, Vietnam", "Photography tour guide for iconic Da Nang shots.", 4.7 },
                        { "guide.quang.do@fellow4u.com", "Quang", "Do", "Da Nang, Vietnam", "Cycling tour specialist along My Khe Beach.", 4.5 },
                        { "guide.hanh.tran@fellow4u.com", "Hanh", "Tran", "Da Nang, Vietnam", "Night market and local street food guide.", 4.8 },
                        { "guide.son.phan@fellow4u.com", "Son", "Phan", "Da Nang, Vietnam", "Adventure sports guide - kayaking and surfing.", 4.9 },
                        { "guide.huong.ly@fellow4u.com", "Huong", "Ly", "Da Nang, Vietnam", "Full-day city discovery for first-time visitors.", 4.6 },
                        { "guide.bach.ngo@fellow4u.com", "Bach", "Ngo", "Da Nang, Vietnam", "Museum and heritage specialist guide.", 4.7 },
                        { "guide.thuy.hoang@fellow4u.com", "Thuy", "Hoang", "Da Nang, Vietnam", "Family-friendly tour guide for all ages.", 4.8 },
                        { "guide.viet.ta@fellow4u.com", "Viet", "Ta", "Da Nang, Vietnam", "Deep sea fishing and island hopping guide.", 4.6 },
                        { "guide.nhi.cao@fellow4u.com", "Nhi", "Cao", "Da Nang, Vietnam", "Wellness and yoga retreat guide near Son Tra.", 4.7 },
                        { "guide.hung.dinh@fellow4u.com", "Hung", "Dinh", "Da Nang, Vietnam", "History buff guide covering French colonial sites.", 4.5 },
                        { "guide.thi.luong@fellow4u.com", "Thi", "Luong", "Da Nang, Vietnam", "Waterpark and entertainment district guide.", 4.4 },
                        { "guide.cuong.trinh@fellow4u.com", "Cuong", "Trinh", "Da Nang, Vietnam", "Local coffee culture and artisan craft guide.", 4.8 },
                        { "guide.oanh.nguyen@fellow4u.com", "Oanh", "Nguyen", "Da Nang, Vietnam", "Shopping and souvenirs specialist guide.", 4.5 },
                        { "guide.khoa.le@fellow4u.com", "Khoa", "Le", "Da Nang, Vietnam", "Sunrise hiker guide to Son Tra Peninsula summit.", 4.9 },

                        // ── Hanoi (15 guides) ──
                        { "guide.linh.hana@fellow4u.com", "Linh", "Hana", "Hanoi, Vietnam", "Old Quarter walking tour specialist.", 4.9 },
                        { "guide.emmy.guide@fellow4u.com", "Emmy", "Nguyen", "Hanoi, Vietnam", "Hoan Kiem Lake and cultural heritage expert.", 4.8 },
                        { "guide.nam.hoang@fellow4u.com", "Nam", "Hoang", "Hanoi, Vietnam", "Street food cycling tour through Hanoi alleys.", 4.7 },
                        { "guide.phuong.bui@fellow4u.com", "Phuong", "Bui", "Hanoi, Vietnam", "Temple of Literature and ancient history guide.", 4.8 },
                        { "guide.trang.do@fellow4u.com", "Trang", "Do", "Hanoi, Vietnam", "Water puppet show and traditional arts guide.", 4.6 },
                        { "guide.long.nguyen@fellow4u.com", "Long", "Nguyen", "Hanoi, Vietnam", "Night market and bia hoi corner social guide.", 4.7 },
                        { "guide.my.pham@fellow4u.com", "My", "Pham", "Hanoi, Vietnam", "French Quarter and architecture tour guide.", 4.5 },
                        { "guide.duc.ha@fellow4u.com", "Duc", "Ha", "Hanoi, Vietnam", "Ho Chi Minh Mausoleum and political history guide.", 4.8 },
                        { "guide.tuyet.ly@fellow4u.com", "Tuyet", "Ly", "Hanoi, Vietnam", "Hanoi Museum of Fine Arts cultural guide.", 4.6 },
                        { "guide.bao.vo@fellow4u.com", "Bao", "Vo", "Hanoi, Vietnam", "Day trip to Ninh Binh and Trang An caves.", 4.9 },
                        { "guide.an.tran@fellow4u.com", "An", "Tran", "Hanoi, Vietnam", "Silk village and traditional craft workshop guide.", 4.7 },
                        { "guide.lien.dang@fellow4u.com", "Lien", "Dang", "Hanoi, Vietnam", "Hoa Lo Prison and war history specialist.", 4.5 },
                        { "guide.hai.le@fellow4u.com", "Hai", "Le", "Hanoi, Vietnam", "Botanical garden and West Lake sunset guide.", 4.6 },
                        { "guide.thao.vu@fellow4u.com", "Thao", "Vu", "Hanoi, Vietnam", "Dimsum and Vietnamese breakfast food tour.", 4.8 },
                        { "guide.tam.ngo@fellow4u.com", "Tam", "Ngo", "Hanoi, Vietnam", "Budget backpacker guide through Hanoi.", 4.4 },

                        // ── Ho Chi Minh City (15 guides) ──
                        { "guide.khai.ho@fellow4u.com", "Khai", "Ho", "Ho Chi Minh City, Vietnam", "Saigon street food scooter tour specialist.", 4.9 },
                        { "guide.linh.saigon@fellow4u.com", "Linh", "Phan", "Ho Chi Minh City, Vietnam", "War history and Cu Chi Tunnels expert guide.", 4.8 },
                        { "guide.nga.truong@fellow4u.com", "Nga", "Truong", "Ho Chi Minh City, Vietnam", "Ben Thanh Market and local shopping guide.", 4.6 },
                        { "guide.son.nguyen@fellow4u.com", "Son", "Nguyen", "Ho Chi Minh City, Vietnam", "Rooftop bar and nightlife district guide.", 4.7 },
                        { "guide.quynh.le@fellow4u.com", "Quynh", "Le", "Ho Chi Minh City, Vietnam", "Reunification Palace and French colonial tour.", 4.8 },
                        { "guide.trung.vu@fellow4u.com", "Trung", "Vu", "Ho Chi Minh City, Vietnam", "Mekong Delta day trip from Saigon specialist.", 4.9 },
                        { "guide.yen.pham@fellow4u.com", "Yen", "Pham", "Ho Chi Minh City, Vietnam", "Art gallery and creative district guide.", 4.6 },
                        { "guide.hoa.tran@fellow4u.com", "Hoa", "Tran", "Ho Chi Minh City, Vietnam", "Botanic Garden and city park relaxation guide.", 4.5 },
                        { "guide.tung.bui@fellow4u.com", "Tung", "Bui", "Ho Chi Minh City, Vietnam", "Day and night photography tour guide.", 4.7 },
                        { "guide.viet.hcm@fellow4u.com", "Viet", "Nguyen", "Ho Chi Minh City, Vietnam", "Craft beer and local drink culture guide.", 4.6 },
                        { "guide.anh.do@fellow4u.com", "Anh", "Do", "Ho Chi Minh City, Vietnam", "Cholon Chinatown and Chinese heritage guide.", 4.7 },
                        { "guide.hiep.vo@fellow4u.com", "Hiep", "Vo", "Ho Chi Minh City, Vietnam", "Vegetarian and vegan food trail guide.", 4.8 },
                        { "guide.dung.hoang@fellow4u.com", "Dung", "Hoang", "Ho Chi Minh City, Vietnam", "Vintage market and retro Saigon guide.", 4.5 },
                        { "guide.chi.nguyen@fellow4u.com", "Chi", "Nguyen", "Ho Chi Minh City, Vietnam", "City cycling tour along Saigon River.", 4.6 },
                        { "guide.phat.le@fellow4u.com", "Phat", "Le", "Ho Chi Minh City, Vietnam", "Budget travel and hostel trail guide.", 4.4 },

                        // ── Hoi An (10 guides) ──
                        { "guide.thao.hoian@fellow4u.com", "Phuong", "Thao", "Hoi An, Vietnam", "Lantern festival and Ancient Town night tour.", 4.9 },
                        { "guide.minh.hoian@fellow4u.com", "Minh", "Tran", "Hoi An, Vietnam", "Tailor shop and silk fabric specialist guide.", 4.7 },
                        { "guide.kim.le@fellow4u.com", "Kim", "Le", "Hoi An, Vietnam", "Cooking class and local market guide.", 4.8 },
                        { "guide.thanh.hoian@fellow4u.com", "Thanh", "Vo", "Hoi An, Vietnam", "Bicycle tour through rice paddies and villages.", 4.6 },
                        { "guide.nga.hoian@fellow4u.com", "Nga", "Pham", "Hoi An, Vietnam", "Japanese bridge and heritage architecture tour.", 4.7 },
                        { "guide.sang.nguyen@fellow4u.com", "Sang", "Nguyen", "Hoi An, Vietnam", "River boat tour at sunset guide.", 4.8 },
                        { "guide.tuong.bui@fellow4u.com", "Tuong", "Bui", "Hoi An, Vietnam", "Pottery village and craft workshop guide.", 4.5 },
                        { "guide.xuan.tran@fellow4u.com", "Xuan", "Tran", "Hoi An, Vietnam", "Full moon lantern ceremony specialist.", 4.9 },
                        { "guide.phong.le@fellow4u.com", "Phong", "Le", "Hoi An, Vietnam", "Cham Island snorkeling and eco tour guide.", 4.7 },
                        { "guide.uyen.ho@fellow4u.com", "Uyen", "Ho", "Hoi An, Vietnam", "Wedding photo location and romantic tour guide.", 4.8 },

                        // ── Hue (8 guides) ──
                        { "guide.ngoc.diep@fellow4u.com", "Ngoc", "Diep", "Hue, Vietnam", "Imperial Citadel and royal tombs historian.", 4.9 },
                        { "guide.bich.hue@fellow4u.com", "Bich", "Tran", "Hue, Vietnam", "Perfume River sunset boat cruise guide.", 4.8 },
                        { "guide.long.hue@fellow4u.com", "Long", "Nguyen", "Hue, Vietnam", "Hue royal cuisine and food heritage guide.", 4.7 },
                        { "guide.nhu.pham@fellow4u.com", "Nhu", "Pham", "Hue, Vietnam", "Thien Mu Pagoda and Buddhist culture guide.", 4.6 },
                        { "guide.viet.hue@fellow4u.com", "Viet", "Le", "Hue, Vietnam", "Minority culture and tribal village tour.", 4.5 },
                        { "guide.quyen.bui@fellow4u.com", "Quyen", "Bui", "Hue, Vietnam", "Tay Loc market and local daily life guide.", 4.7 },
                        { "guide.hai.hue@fellow4u.com", "Hai", "Vo", "Hue, Vietnam", "Cycling tour along Hue ancient walls.", 4.8 },
                        { "guide.kieu.dang@fellow4u.com", "Kieu", "Dang", "Hue, Vietnam", "Cultural performance and dragon boat show guide.", 4.6 },

                        // ── Sapa (8 guides) ──
                        { "guide.bao.sapa@fellow4u.com", "Gia", "Bao", "Sapa, Vietnam", "Fansipan summit trekking specialist guide.", 4.9 },
                        { "guide.mai.sapa@fellow4u.com", "Mai", "Nguyen", "Sapa, Vietnam", "Rice terrace photography and homestay guide.", 4.8 },
                        { "guide.linh.sapa@fellow4u.com", "Linh", "Tran", "Sapa, Vietnam", "Hmong village cultural immersion guide.", 4.7 },
                        { "guide.trung.sapa@fellow4u.com", "Trung", "Bui", "Sapa, Vietnam", "Cloud hunting and fog landscape guide.", 4.8 },
                        { "guide.son.sapa@fellow4u.com", "Son", "Pham", "Sapa, Vietnam", "Two-day trekking to Ta Van village guide.", 4.9 },
                        { "guide.huong.sapa@fellow4u.com", "Huong", "Le", "Sapa, Vietnam", "Winter snow season Sapa specialist.", 4.7 },
                        { "guide.toan.vu@fellow4u.com", "Toan", "Vu", "Sapa, Vietnam", "Muong Hoa valley and waterfall guide.", 4.6 },
                        { "guide.diep.sapa@fellow4u.com", "Diep", "Hoang", "Sapa, Vietnam", "Ethnic minority market and culture tour.", 4.8 },

                        // ── Phu Quoc (8 guides) ──
                        { "guide.gia.bao@fellow4u.com", "Gia", "Bao", "Phu Quoc, Vietnam", "Sunset beach cocktail and resort tour.", 4.8 },
                        { "guide.nam.phuquoc@fellow4u.com", "Nam", "Tran", "Phu Quoc, Vietnam", "Deep sea fishing and island hopping specialist.", 4.9 },
                        { "guide.linh.phuquoc@fellow4u.com", "Linh", "Nguyen", "Phu Quoc, Vietnam", "North island eco-tour and national park guide.", 4.7 },
                        { "guide.phuc.le@fellow4u.com", "Phuc", "Le", "Phu Quoc, Vietnam", "Snorkeling and coral reef diving guide.", 4.8 },
                        { "guide.thao.phuquoc@fellow4u.com", "Thao", "Pham", "Phu Quoc, Vietnam", "Night squid fishing and seafood tour.", 4.6 },
                        { "guide.hien.bui@fellow4u.com", "Hien", "Bui", "Phu Quoc, Vietnam", "Pepper farm and fish sauce factory tour.", 4.5 },
                        { "guide.tai.nguyen@fellow4u.com", "Tai", "Nguyen", "Phu Quoc, Vietnam", "Cable car and Sun World theme park guide.", 4.7 },
                        { "guide.loan.tran@fellow4u.com", "Loan", "Tran", "Phu Quoc, Vietnam", "Family resort and water sport guide.", 4.8 },

                        // ── Ha Long (8 guides) ──
                        { "guide.linh.halong@fellow4u.com", "Linh", "Hana", "Ha Long, Vietnam", "Overnight cruise and cave exploration specialist.", 4.9 },
                        { "guide.duc.halong@fellow4u.com", "Duc", "Phan", "Ha Long, Vietnam", "Kayaking through limestone karsts guide.", 4.8 },
                        { "guide.minh.halong@fellow4u.com", "Minh", "Le", "Ha Long, Vietnam", "Fishing village and floating market guide.", 4.7 },
                        { "guide.thu.halong@fellow4u.com", "Thu", "Vo", "Ha Long, Vietnam", "Sung Sot cave and Ti Top island tour.", 4.8 },
                        { "guide.tien.bui@fellow4u.com", "Tien", "Bui", "Ha Long, Vietnam", "Sunrise photography cruise guide.", 4.9 },
                        { "guide.nhan.nguyen@fellow4u.com", "Nhan", "Nguyen", "Ha Long, Vietnam", "Budget cruise and group tour organizer.", 4.5 },
                        { "guide.chi.halong@fellow4u.com", "Chi", "Pham", "Ha Long, Vietnam", "Seafood dinner cruise and cooking class.", 4.7 },
                        { "guide.kim.halong@fellow4u.com", "Kim", "Hoang", "Ha Long, Vietnam", "Lan Ha Bay alternative route specialist.", 4.8 },

                        // ── Nha Trang (8 guides) ──
                        { "guide.nam.nhatrang@fellow4u.com", "Hoang", "Nam", "Nha Trang, Vietnam", "Vinpearl Island and beach resort guide.", 4.8 },
                        { "guide.anh.nhatrang@fellow4u.com", "Anh", "Le", "Nha Trang, Vietnam", "Scuba diving and snorkeling tour specialist.", 4.9 },
                        { "guide.trang.nhatrang@fellow4u.com", "Trang", "Pham", "Nha Trang, Vietnam", "Mud bath and hot springs wellness guide.", 4.7 },
                        { "guide.hung.nhatrang@fellow4u.com", "Hung", "Bui", "Nha Trang, Vietnam", "Po Nagar Tower Cham heritage guide.", 4.6 },
                        { "guide.lam.tran@fellow4u.com", "Lam", "Tran", "Nha Trang, Vietnam", "Island 4-stop boat tour specialist.", 4.8 },
                        { "guide.tuyen.nguyen@fellow4u.com", "Tuyen", "Nguyen", "Nha Trang, Vietnam", "Night seafood market and fishing pier guide.", 4.5 },
                        { "guide.kien.le@fellow4u.com", "Kien", "Le", "Nha Trang, Vietnam", "Instagrammable beach spot photography guide.", 4.7 },
                        { "guide.ngan.vo@fellow4u.com", "Ngan", "Vo", "Nha Trang, Vietnam", "Budget travel hacks and local tips guide.", 4.4 },

                        // ── Can Tho / Mekong (4 guides) ──
                        { "guide.thao.demo@fellow4u.com", "Phuong", "Thao", "Can Tho, Vietnam", "Floating market sunrise boat tour guide.", 4.9 },
                        { "guide.tien.cantho@fellow4u.com", "Tien", "Nguyen", "Can Tho, Vietnam", "Orchard farm and tropical fruit tasting guide.", 4.7 },
                        { "guide.hau.tran@fellow4u.com", "Hau", "Tran", "Can Tho, Vietnam", "River delta canal rowing boat guide.", 4.8 },
                        { "guide.muoi.le@fellow4u.com", "Muoi", "Le", "Can Tho, Vietnam", "Traditional craft village and rural life guide.", 4.6 },

                        // ── Mui Ne / Phan Thiet (4 guides) ──
                        { "guide.thi.muine@fellow4u.com", "Thi", "Nguyen", "Mui Ne, Vietnam", "Sand dune jeep tour at sunrise specialist.", 4.8 },
                        { "guide.duy.pham@fellow4u.com", "Duy", "Pham", "Mui Ne, Vietnam", "Kitesurfing lessons and beach sport guide.", 4.9 },
                        { "guide.mai.muine@fellow4u.com", "Mai", "Tran", "Mui Ne, Vietnam", "Fairy Stream and Red Canyon hiking guide.", 4.7 },
                        { "guide.hung.muine@fellow4u.com", "Hung", "Le", "Mui Ne, Vietnam", "Fishing village and local seafood guide.", 4.6 },
                };

                for (Object[] guide : guides) {
                        String email = (String) guide[0];
                        if (!userRepository.existsByEmail(email)) {
                                String firstName = (String) guide[1];
                                String lastName = (String) guide[2];
                                String fullName = (firstName + " " + lastName).trim();
                                double rating = (Double) guide[5];
                                // Use different avatar background colors based on rating
                                String bgColor = rating >= 4.8 ? "00CEA6" : rating >= 4.6 ? "0077B6" : "F4A261";
                                userRepository.save(User.builder()
                                                .email(email)
                                                .password(passwordEncoder.encode("guide123"))
                                                .firstName(firstName)
                                                .lastName(lastName)
                                                .role("GUIDE")
                                                .location((String) guide[3])
                                                .avatarUrl("https://ui-avatars.com/api/?name="
                                                                + fullName.replace(" ", "+")
                                                                + "&background=" + bgColor + "&color=ffffff&size=200&bold=true")
                                                .bio((String) guide[4])
                                                .rating(rating)
                                                .reviewCount(80 + fullName.length() * 2)
                                                .build());
                        }
                }
        }


        private void ensureDemoAttractions() {
                Object[][] attractions = {
                                { "Dragon Bridge", "Da Nang", "http://127.0.0.1:8080/uploads/location/images.jpg" },
                                { "My Khe Beach", "Da Nang", "http://127.0.0.1:8080/uploads/location/images_1.jpg" },
                                { "Hoan Kiem Lake", "Hanoi", "http://127.0.0.1:8080/uploads/location/tải xuống.jpg" },
                                { "Hoi An Ancient Town", "Hoi An", "http://127.0.0.1:8080/uploads/location/tải xuống (1).jpg" },
                                { "Imperial City", "Hue", "http://127.0.0.1:8080/uploads/location/tải xuống (2).jpg" },
                                { "Ben Thanh Market", "Ho Chi Minh City", "http://127.0.0.1:8080/uploads/location/tải xuống (3).jpg" },
                                { "Ha Long Bay", "Ha Long", "http://127.0.0.1:8080/uploads/location/tải xuống (4).jpg" },
                                { "Sapa Rice Terraces", "Sapa", "http://127.0.0.1:8080/uploads/location/tải xuống (5).jpg" }
                };

                for (Object[] attraction : attractions) {
                        String name = (String) attraction[0];
                        boolean exists = attractionRepository.findAll().stream()
                                        .anyMatch(item -> name.equalsIgnoreCase(item.getName()));
                        if (!exists) {
                                attractionRepository.save(Attraction.builder()
                                                .name(name)
                                                .city((String) attraction[1])
                                                .imageUrl((String) attraction[2])
                                                .build());
                        }
                }
        }

        private void ensureDemoTours() {
                Object[][] tours = {
                                { "Da Nang - Ba Na - Hoi An", "Da Nang, Vietnam", "http://127.0.0.1:8080/uploads/location/tải xuống (6).jpg", "135", "TOP_JOURNEY", "3 days", 9, "Cable car, Golden Bridge, Hoi An lantern streets, and local dinner." },
                                { "Hanoi City Discovery", "Hanoi, Vietnam", "http://127.0.0.1:8080/uploads/location/tải xuống (7).jpg", "105", "FEATURED", "1 day", 12, "Old Quarter walk, Hoan Kiem Lake, Temple of Literature, and street food stops." },
                                { "Saigon Street Food", "Ho Chi Minh City, Vietnam", "http://127.0.0.1:8080/uploads/location/tải xuống (3).jpg", "79", "FEATURED", "1 night", 4, "Evening scooter food route with local markets, hidden snacks, and coffee." },
                                { "Ha Long Bay Cruise", "Ha Long, Vietnam", "http://127.0.0.1:8080/uploads/location/tải xuống (4).jpg", "220", "TOP_JOURNEY", "2 days", 16, "Overnight cruise, cave visit, kayaking, seafood dinner, and sunrise deck time." },
                                { "Sapa Trekking Adventure", "Sapa, Vietnam", "http://127.0.0.1:8080/uploads/location/tải xuống (5).jpg", "180", "REGULAR", "3 days", 23, "Rice terraces, village homestay, mountain viewpoints, and local guide support." },
                                { "Hue Royal Heritage", "Hue, Vietnam", "http://127.0.0.1:8080/uploads/location/tải xuống (2).jpg", "125", "REGULAR", "2 days", 20, "Imperial Citadel, royal tombs, Perfume River, and Hue cuisine highlights." },
                                { "Mekong Delta Boat", "Can Tho, Vietnam", "http://127.0.0.1:8080/uploads/location/images.jpg", "145", "FEATURED", "2 days", 28, "Floating market, orchard visits, canal boat ride, and countryside lunch." },
                                { "Phu Quoc Sunset", "Phu Quoc, Vietnam", "http://127.0.0.1:8080/uploads/location/images_1.jpg", "160", "REGULAR", "2 days", 34, "Island beaches, snorkeling window, sunset dinner, and night market walk." }
                };

                for (Object[] item : tours) {
                        String title = (String) item[0];
                        Tour tour = findTourByExactTitle(title);
                        if (tour == null) {
                                tour = new Tour();
                                tour.setTitle(title);
                        }

                        tour.setLocation((String) item[1]);
                        tour.setImageUrl((String) item[2]);
                        tour.setPrice(new BigDecimal((String) item[3]));
                        tour.setCategory(Tour.TourCategory.valueOf((String) item[4]));
                        tour.setDuration((String) item[5]);
                        tour.setStartDate(LocalDate.now().plusDays((Integer) item[6]));
                        tour.setDescription((String) item[7]);
                        tour.setRating(4.6 + (title.length() % 4) * 0.1);
                        tour.setReviewCount(40 + title.length() * 3);
                        tourRepository.save(tour);
                }
        }

        private void ensureDemoBookings(User traveler) {
                List<Attraction> attractions = attractionRepository.findAll();
                Object[][] bookings = {
                                // ── CURRENT ──
                                { "Dragon Bridge Trip", "Da Nang, Vietnam", 0, "09:00 - 11:00", "Tuan Tran", 2, "40.00", "CURRENT", "PAID_100" },
                                { "Ba Na Hills Adventure", "Da Nang, Vietnam", 1, "07:00 - 17:00", "Hoang Nam", 3, "270.00", "CURRENT", "PAID_50" },

                                // ── NEXT ──
                                { "Ho Guom Trip", "Hanoi, Vietnam", 3, "08:00 - 10:00", "Emmy", 2, "210.00", "NEXT", "PAID_50" },
                                { "Ho Chi Minh Mausoleum", "Hanoi, Vietnam", 5, "08:00 - 10:00", "Emmy", 2, "180.00", "NEXT", "UNPAID" },
                                { "Duc Ba Church Tour", "Ho Chi Minh City, Vietnam", 8, "09:00 - 11:00", "Khai Ho", 3, "237.00", "NEXT", "UNPAID" },
                                { "Ha Long Bay Cruise", "Ha Long, Vietnam", 10, "07:00 - 18:00", "Linh Hana", 4, "880.00", "NEXT", "PAID_100" },
                                { "Mekong Delta Boat", "Can Tho, Vietnam", 14, "07:30 - 17:00", "Phuong Thao", 2, "290.00", "NEXT", "PAID_50" },
                                { "Phu Quoc Sunset", "Phu Quoc, Vietnam", 21, "14:00 - 20:00", "Gia Bao", 2, "320.00", "NEXT", "UNPAID" },

                                // ── PAST ──
                                { "Quoc Tu Giam Temple", "Hanoi, Vietnam", -14, "09:00 - 11:00", "Khai Ho", 1, "105.00", "PAST", "PAID_100" },
                                { "Dinh Doc Lap Palace", "Ho Chi Minh City, Vietnam", -20, "10:00 - 12:00", "Emmy", 2, "158.00", "PAST", "PAID_100" },
                                { "Sapa Trekking Adventure", "Sapa, Vietnam", -35, "07:00 - 17:00", "Gia Bao", 2, "360.00", "PAST", "PAID_100" },
                                { "Hue Royal Heritage", "Hue, Vietnam", -50, "08:00 - 16:00", "Ngoc Diep", 2, "250.00", "PAST", "PAID_100" },
                                { "Hoi An Lantern Night", "Hoi An, Vietnam", -65, "17:00 - 21:00", "Phuong Thao", 3, "195.00", "PAST", "PAID_100" },
                                { "Da Nang - Ba Na - Hoi An", "Da Nang, Vietnam", -90, "07:00 - 18:00", "Tuan Tran", 2, "270.00", "PAST", "PAID_50" },
        };

                for (Object[] item : bookings) {
                        String tripTitle = (String) item[0];
                        LocalDate date = LocalDate.now().plusDays((Integer) item[2]);
                        String guideName = (String) item[4];
                        boolean exists = bookingRepository.findAll().stream()
                                        .anyMatch(booking -> tripTitle.equalsIgnoreCase(booking.getTripTitle())
                                                        && date.equals(booking.getDate())
                                                        && guideName.equalsIgnoreCase(booking.getGuideName()));
                        if (!exists) {
                                bookingRepository.save(Booking.builder()
                                                .tripTitle(tripTitle)
                                                .location((String) item[1])
                                                .date(date)
                                                .timeSlot((String) item[3])
                                                .guideName(guideName)
                                                .guideAvatarUrl("https://ui-avatars.com/api/?name="
                                                                + guideName.replace(" ", "+")
                                                                + "&background=00CEA6&color=ffffff&size=200")
                                                .travelers((Integer) item[5])
                                                .totalFee(new BigDecimal((String) item[6]))
                                                .status((String) item[7])
                                                .paymentStatus((String) item[8])
                                                .attractions(attractions.isEmpty() ? List.of()
                                                                : attractions.stream().limit(3).toList())
                                                .user(traveler)
                                                .build());
                        }
                }
        }


        private void ensureDemoWishlist(User traveler) {
                if (traveler.getBookmarkedTours() == null || traveler.getBookmarkedTours().isEmpty()) {
                        tourRepository.findAll().stream()
                                        .limit(4)
                                        .forEach(tour -> traveler.getBookmarkedTours().add(tour));
                        userRepository.save(traveler);
                }
        }

        private void ensureDemoAdminChat(User traveler) {
                User admin = userRepository.findByEmail("admin@fellow4u.com").orElse(null);
                if (admin == null) {
                        return;
                }

                boolean hasAdminChat = chatMessageRepository.findChatHistory(admin, traveler).stream()
                                .anyMatch(message -> message.getContent() != null
                                                && message.getContent().contains("Fellow4U"));
                if (hasAdminChat) {
                        return;
                }

                chatMessageRepository.save(ChatMessage.builder()
                                .sender(admin)
                                .receiver(traveler)
                                .content("Hi, this is Fellow4U. How can we help you?")
                                .timestamp(java.time.LocalDateTime.now().minusMinutes(42))
                                .isRead(true)
                                .build());
                chatMessageRepository.save(ChatMessage.builder()
                                .sender(admin)
                                .receiver(traveler)
                                .content("It was populated in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus.")
                                .timestamp(java.time.LocalDateTime.now().minusMinutes(40))
                                .isRead(true)
                                .build());
                chatMessageRepository.save(ChatMessage.builder()
                                .sender(traveler)
                                .receiver(admin)
                                .content("as opposed to using Content here")
                                .timestamp(java.time.LocalDateTime.now().minusMinutes(31))
                                .isRead(false)
                                .build());
                chatMessageRepository.save(ChatMessage.builder()
                                .sender(traveler)
                                .receiver(admin)
                                .content("It is a long established fact that a reader will be distracted by the")
                                .timestamp(java.time.LocalDateTime.now().minusMinutes(29))
                                .isRead(false)
                                .build());
                chatMessageRepository.save(ChatMessage.builder()
                                .sender(traveler)
                                .receiver(admin)
                                .content("image::http://127.0.0.1:8080/uploads/location/images.jpg|http://127.0.0.1:8080/uploads/location/tai_xuong.jpg|http://127.0.0.1:8080/uploads/location/tai_xuong_3.jpg|http://127.0.0.1:8080/uploads/location/tai_xuong_1.jpg|http://127.0.0.1:8080/uploads/location/images_1.jpg|http://127.0.0.1:8080/uploads/location/tai_xuong_4.jpg")
                                .timestamp(java.time.LocalDateTime.now().minusMinutes(18))
                                .isRead(false)
                                .build());
                chatMessageRepository.save(ChatMessage.builder()
                                .sender(traveler)
                                .receiver(admin)
                                .content("audio::demo-admin-chat-audio|249")
                                .timestamp(java.time.LocalDateTime.now().minusMinutes(8))
                                .isRead(false)
                                .build());
        }

        private void ensureDemoAdminBilling() {
                User admin = userRepository.findByEmail("admin@fellow4u.com").orElse(null);
                if (admin == null) {
                        return;
                }

                boolean hasAdminCard = paymentMethodRepository.findByUser(admin).stream()
                                .anyMatch(method -> "CARD".equalsIgnoreCase(method.getType()));
                if (!hasAdminCard) {
                        paymentMethodRepository.save(PaymentMethod.builder()
                                        .name("Visa **** 2768")
                                        .identifier("**** **** **** 2768")
                                        .provider("VISA")
                                        .type("CARD")
                                        .user(admin)
                                        .build());
                }

                if (adminSubscriptionRepository.findFirstByAdminUserOrderByStartedAtDesc(admin).isEmpty()) {
                        adminSubscriptionRepository.save(AdminSubscription.builder()
                                        .adminUser(admin)
                                        .planName("Starter")
                                        .yearlyPrice(BigDecimal.valueOf(100))
                                        .startedAt(LocalDate.now().minusMonths(2))
                                        .validUntil(LocalDate.now().plusMonths(10))
                                        .build());
                }
        }

        private Tour findTourByExactTitle(String title) {
                return tourRepository.findAll().stream()
                                .filter(tour -> title.equalsIgnoreCase(tour.getTitle()))
                                .findFirst()
                                .orElse(null);
        }
}
