package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.entity.PaymentMethod;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PaymentMethodRepository extends JpaRepository<PaymentMethod, String> {
    List<PaymentMethod> findByUser(User user);
}
