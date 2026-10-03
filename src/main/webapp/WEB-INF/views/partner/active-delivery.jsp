<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="${empty booking ? 'Active Deliveries' : 'Delivery #' += booking.id}"/>
    <jsp:param name="nav" value="delivery"/>
    <jsp:param name="inlineErrors" value="${not empty booking and booking.status == 'ARRIVED_AT_DESTINATION'}"/>
</jsp:include>

<c:choose>
    <%-- ===== List of active deliveries ===== --%>
    <c:when test="${empty booking}">
        <div class="page-head">
            <div>
                <h1>Active Deliveries</h1>
                <p>Accepted bookings that are on their way. Open one to update its status and share your location.</p>
            </div>
        </div>
        <section class="card card-flush">
            <c:if test="${empty activeBookings}">
                <div class="empty">
                    <div class="empty-icon"><svg class="i"><use href="${ico}#route"/></svg></div>
                    <h3>No active deliveries</h3>
                    <p>Accept a booking request to start a delivery.</p>
                    <a class="btn btn-primary" href="${ctx}/partner/requests"><svg class="i"><use href="${ico}#inbox"/></svg><span>Booking Requests</span></a>
                </div>
            </c:if>
            <c:forEach var="b" items="${activeBookings}">
                <a class="list-card" href="${ctx}/partner/delivery?id=${b.id}">
                    <span class="lc-icon"><svg class="i"><use href="${ico}#package"/></svg></span>
                    <span class="lc-main">
                        <span class="lc-title">#${b.id} &middot; <c:out value="${b.productName}"/> &middot; <fmt:formatNumber value="${b.weight}" maxFractionDigits="2"/> kg</span>
                        <span class="lc-sub" style="display:block"><c:out value="${b.pickupAddress}"/> &rarr; <c:out value="${b.destinationAddress}"/></span>
                    </span>
                    <span class="lc-right">
                        <span class="badge tone-${b.status.tone}">${b.status.stepLabel}</span>
                        <svg class="i"><use href="${ico}#chevron-right"/></svg>
                    </span>
                </a>
            </c:forEach>
        </section>
    </c:when>

    <%-- ===== One delivery ===== --%>
    <c:otherwise>
        <c:set var="vt" value="${fn:toLowerCase(booking.vehicleType)}"/>
        <a class="back-link" href="${ctx}/partner/delivery"><svg class="i i-sm"><use href="${ico}#arrow-left"/></svg>Active deliveries</a>
        <div class="page-head">
            <div>
                <div class="row-flex"><h1>Delivery #${booking.id}</h1><span class="badge tone-${booking.status.tone}">${booking.status.stepLabel}</span></div>
                <p><c:out value="${booking.productName}"/> &middot; <fmt:formatNumber value="${booking.weight}" maxFractionDigits="2"/> kg &middot; for <c:out value="${booking.customerName}"/></p>
            </div>
        </div>

        <div class="grid-main-side">
            <div class="stack">
                <%-- Next action for the current status --%>
                <c:choose>
                    <c:when test="${booking.status == 'ARRIVED_AT_DESTINATION'}">
                        <section class="card">
                            <%-- OTP is 4 digits (OTPGenerator); the boxes fill the hidden "otp" field sent to VerifyOTPServlet --%>
                            <form method="post" action="${ctx}/partner/verify-otp" class="otp-card" id="otpForm">
                                <div class="empty-icon"><svg class="i"><use href="${ico}#shield"/></svg></div>
                                <div class="eyebrow">Delivery verification</div>
                                <h2>Enter the customer's OTP</h2>
                                <p class="muted" style="margin-top:6px">Ask <c:out value="${booking.customerName}"/> for the code shown on their booking.</p>
                                <input type="hidden" name="bookingId" value="${booking.id}">
                                <input type="hidden" name="otp" id="otpValue">
                                <div class="otp-inputs ${not empty sessionScope.flashError ? 'has-error shake' : ''}" id="otpBoxes">
                                    <c:forEach begin="1" end="4" var="n">
                                        <input type="text" inputmode="numeric" maxlength="1" pattern="[0-9]" aria-label="OTP digit ${n}" autocomplete="one-time-code" ${n == 1 ? 'autofocus' : ''}>
                                    </c:forEach>
                                </div>
                                <c:if test="${not empty sessionScope.flashError}">
                                    <p class="field-error" role="alert" style="margin:-6px 0 14px"><c:out value="${sessionScope.flashError}"/></p>
                                    <c:remove var="flashError" scope="session"/>
                                </c:if>
                                <button type="submit" class="btn btn-primary btn-lg btn-block" id="otpSubmit" disabled><span>Verify OTP</span></button>
                            </form>
                        </section>
                    </c:when>
                    <c:when test="${booking.status == 'DELIVERED'}">
                        <section class="card">
                            <div class="success-hero">
                                <div class="check"><svg class="i"><use href="${ico}#check"/></svg></div>
                                <h2>Delivery Verified &#10003;</h2>
                                <p>Shipment successfully delivered. Complete the delivery to free up the space on your vehicle.</p>
                                <form method="post" action="${ctx}/partner/delivery" style="margin-top:18px">
                                    <input type="hidden" name="bookingId" value="${booking.id}">
                                    <input type="hidden" name="action" value="complete">
                                    <button type="submit" class="btn btn-primary btn-lg"><svg class="i"><use href="${ico}#check-circle"/></svg><span>Complete delivery</span></button>
                                </form>
                            </div>
                        </section>
                    </c:when>
                    <c:when test="${booking.status.activeDelivery and not empty nextStatus}">
                        <section class="card">
                            <div class="row-flex">
                                <div>
                                    <div class="section-label" style="margin-bottom:4px">Next step</div>
                                    <h2>${nextStatus.stepLabel}</h2>
                                    <p class="muted small">Tap when this has happened. The customer sees the update on their tracking page.</p>
                                </div>
                                <form method="post" action="${ctx}/partner/delivery" class="push-right">
                                    <input type="hidden" name="bookingId" value="${booking.id}">
                                    <button type="submit" class="btn btn-primary btn-lg"><span>Mark as ${nextStatus.stepLabel}</span><svg class="i"><use href="${ico}#arrow-right"/></svg></button>
                                </form>
                            </div>
                        </section>
                    </c:when>
                </c:choose>

                <section class="card">
                    <div class="card-head"><h2>Delivery status</h2></div>
                    <ol class="timeline">
                        <c:forEach var="s" items="${statuses}">
                            <c:if test="${s != 'CANCELLED' and s != 'SEARCHING'}">
                                <li class="${s.ordinal() < booking.status.ordinal() or booking.status == 'COMPLETED' ? 'done' : (s == booking.status ? 'current' : '')}">
                                    <span class="dot"><svg class="i"><use href="${ico}#check"/></svg></span>
                                    <div>
                                        <div class="t-label">${s.stepLabel}<span class="now">Now</span></div>
                                        <div class="t-sub">
                                            <c:choose>
                                                <c:when test="${s == 'MATCHED'}">${booking.createdAt.format(dtf)}</c:when>
                                                <c:when test="${s == 'PICKED_UP' and not empty booking.pickupTime}">${booking.pickupTime.format(dtf)}</c:when>
                                                <c:when test="${s == 'DELIVERED' and not empty booking.deliveryTime}">${booking.deliveryTime.format(dtf)}</c:when>
                                            </c:choose>
                                        </div>
                                    </div>
                                </li>
                            </c:if>
                        </c:forEach>
                    </ol>
                </section>
            </div>

            <div class="stack">
                <section class="card">
                    <div class="card-head"><h2>Details</h2></div>
                    <div class="route" style="margin-bottom:16px">
                        <div class="route-stop"><span class="route-dot"></span><div><div class="k">Pickup</div><div class="v"><c:out value="${booking.pickupAddress}"/></div></div></div>
                        <div class="route-stop to"><span class="route-dot"></span><div><div class="k">Drop</div><div class="v"><c:out value="${booking.destinationAddress}"/></div></div></div>
                    </div>
                    <dl class="summary-list">
                        <div><dt>Customer</dt><dd><c:out value="${booking.customerName}"/></dd></div>
                        <div><dt>Phone</dt><dd><a href="tel:<c:out value='${booking.customerPhone}'/>"><c:out value="${booking.customerPhone}"/></a></dd></div>
                        <div><dt>Product</dt><dd><c:out value="${booking.productName}"/></dd></div>
                        <div><dt>Weight</dt><dd><fmt:formatNumber value="${booking.weight}" maxFractionDigits="2"/> kg</dd></div>
                        <div><dt>Vehicle</dt><dd style="text-transform:capitalize">${vt} <span class="reg-plate"><c:out value="${booking.vehicleNumber}"/></span></dd></div>
                        <div><dt>Fare</dt><dd>&#8377;<fmt:formatNumber value="${booking.estimatedCost}" pattern="#,##0"/></dd></div>
                    </dl>
                </section>

                <c:if test="${booking.status.activeDelivery}">
                    <section class="card location-card" id="location-sharing"
                             data-vehicle-id="${booking.vehicleId}" data-booking-id="${booking.id}"
                             data-interval="${locationIntervalSeconds}">
                        <div class="card-head">
                            <h2>Location sharing</h2>
                            <span class="live push-right" id="shareLive">Sharing</span>
                        </div>
                        <p class="small muted">Your browser sends your position every ${locationIntervalSeconds} seconds so the customer can track you.</p>
                        <p class="small" style="margin:10px 0 14px"><strong>Status:</strong> <span id="shareStatus">Starting...</span></p>
                        <button type="button" class="btn btn-outline btn-sm" id="shareToggle">Pause sharing</button>
                    </section>
                    <script src="${ctx}/assets/js/location-sender.js"></script>
                </c:if>
            </div>
        </div>

        <c:if test="${booking.status == 'ARRIVED_AT_DESTINATION'}">
            <script src="${ctx}/assets/js/otp-input.js"></script>
        </c:if>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
