<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Active delivery"/></jsp:include>

<c:choose>
    <%-- List of active deliveries --%>
    <c:when test="${empty booking}">
        <h1>Active deliveries</h1>
        <c:if test="${empty activeBookings}">
            <div class="card center"><p class="muted">No active deliveries. Accept a request to start one.</p></div>
        </c:if>
        <c:forEach var="b" items="${activeBookings}">
            <a class="card request link-card" href="${pageContext.request.contextPath}/partner/delivery?id=${b.id}">
                <div>
                    <h3>#${b.id} &middot; <c:out value="${b.productName}"/> (${b.weight} kg)</h3>
                    <p><c:out value="${b.pickupAddress}"/> &rarr; <c:out value="${b.destinationAddress}"/></p>
                </div>
                <span class="badge status-${b.status}">${b.status.label}</span>
            </a>
        </c:forEach>
    </c:when>

    <%-- One delivery --%>
    <c:otherwise>
        <div class="page-head">
            <h1>Delivery #${booking.id}</h1>
            <span class="badge status-${booking.status}">${booking.status.label}</span>
        </div>

        <div class="grid-2">
            <section class="card">
                <h2>Details</h2>
                <dl>
                    <dt>Product</dt><dd><c:out value="${booking.productName}"/> (${booking.weight} kg)</dd>
                    <dt>Pickup</dt><dd><c:out value="${booking.pickupAddress}"/></dd>
                    <dt>Drop</dt><dd><c:out value="${booking.destinationAddress}"/></dd>
                    <dt>Customer</dt><dd><c:out value="${booking.customerName}"/>, <c:out value="${booking.customerPhone}"/></dd>
                    <dt>Vehicle</dt><dd>${booking.vehicleType} <c:out value="${booking.vehicleNumber}"/></dd>
                    <dt>Fare</dt><dd>&#8377;<fmt:formatNumber value="${booking.estimatedCost}" pattern="#,##0"/></dd>
                </dl>
            </section>

            <section class="card">
                <h2>Progress</h2>
                <ol class="timeline">
                    <c:forEach var="s" items="${statuses}">
                        <c:if test="${s != 'CANCELLED' and s.ordinal() >= 3}">
                            <li class="${s.ordinal() < booking.status.ordinal() ? 'done' : (s == booking.status ? 'current' : '')}">${s.label}</li>
                        </c:if>
                    </c:forEach>
                </ol>

                <c:choose>
                    <c:when test="${booking.status == 'ARRIVED_AT_DESTINATION'}">
                        <form method="post" action="${pageContext.request.contextPath}/partner/verify-otp" class="otp-form">
                            <input type="hidden" name="bookingId" value="${booking.id}">
                            <label>Enter the customer's OTP
                                <input type="text" name="otp" inputmode="numeric" pattern="[0-9]{4}" maxlength="4" required autofocus>
                            </label>
                            <button type="submit" class="btn btn-primary">Verify OTP</button>
                        </form>
                    </c:when>
                    <c:when test="${booking.status == 'DELIVERED'}">
                        <form method="post" action="${pageContext.request.contextPath}/partner/delivery">
                            <input type="hidden" name="bookingId" value="${booking.id}">
                            <input type="hidden" name="action" value="complete">
                            <button type="submit" class="btn btn-primary btn-block">Complete delivery</button>
                        </form>
                    </c:when>
                    <c:when test="${booking.status.activeDelivery}">
                        <form method="post" action="${pageContext.request.contextPath}/partner/delivery">
                            <input type="hidden" name="bookingId" value="${booking.id}">
                            <button type="submit" class="btn btn-primary btn-block">Mark as: ${nextStatus.label}</button>
                        </form>
                    </c:when>
                </c:choose>
            </section>
        </div>

        <c:if test="${booking.status.activeDelivery}">
            <section class="card" id="location-sharing"
                     data-vehicle-id="${booking.vehicleId}" data-booking-id="${booking.id}"
                     data-interval="${locationIntervalSeconds}">
                <h2>Location sharing</h2>
                <p>Your browser sends your position every ${locationIntervalSeconds} seconds so the customer can track you.</p>
                <p><strong>Status:</strong> <span id="shareStatus">Starting...</span></p>
                <div class="button-row">
                    <button type="button" class="btn btn-outline" id="shareToggle">Pause sharing</button>
                </div>
            </section>
            <script src="${pageContext.request.contextPath}/assets/js/location-sender.js"></script>
        </c:if>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
