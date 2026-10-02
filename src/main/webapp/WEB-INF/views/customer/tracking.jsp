<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Track delivery"/></jsp:include>

<div class="page-head">
    <h1>Tracking booking #${booking.id}</h1>
    <a class="btn btn-outline" href="${pageContext.request.contextPath}/customer/booking?id=${booking.id}">Booking details</a>
</div>

<div id="tracking" data-booking-id="${booking.id}"
     data-pickup-lat="${shipment.pickupLatitude}" data-pickup-lng="${shipment.pickupLongitude}"
     data-dest-lat="${shipment.destinationLatitude}" data-dest-lng="${shipment.destinationLongitude}">

    <div class="grid-2">
        <section class="card">
            <h2>Status</h2>
            <ol class="timeline" id="timeline">
                <c:forEach var="s" items="${statuses}">
                    <c:if test="${s != 'CANCELLED' and s.ordinal() >= 2}">
                        <li data-status="${s}" data-order="${s.ordinal()}"
                            class="${s.ordinal() < tracking.status.ordinal() ? 'done' : (s == tracking.status ? 'current' : '')}">
                            ${s.label}
                        </li>
                    </c:if>
                </c:forEach>
            </ol>
        </section>

        <section class="card">
            <h2>Live location</h2>
            <dl>
                <dt>Status</dt><dd id="statusLabel">${tracking.status.label}</dd>
                <dt>Vehicle position</dt>
                <dd id="position">${empty tracking.latitude ? 'Not shared yet' : tracking.latitude.toString().concat(', ').concat(tracking.longitude)}</dd>
                <dt>Distance to pickup</dt><dd id="toPickup">${empty tracking.distanceToPickupKm ? '-' : tracking.distanceToPickupKm.toString().concat(' km')}</dd>
                <dt>Distance to destination</dt><dd id="toDestination">${empty tracking.distanceToDestinationKm ? '-' : tracking.distanceToDestinationKm.toString().concat(' km')}</dd>
                <dt>Last update</dt><dd id="lastUpdated">-</dd>
            </dl>
            <a id="mapLink" class="btn btn-outline" target="_blank" rel="noopener"
               href="https://www.openstreetmap.org/?mlat=${tracking.latitude}&mlon=${tracking.longitude}#map=15/${tracking.latitude}/${tracking.longitude}"
               ${empty tracking.latitude ? 'hidden' : ''}>View on OpenStreetMap</a>
            <p class="muted small">Updates automatically every 10 seconds.</p>
        </section>
    </div>

    <c:if test="${not empty otp and not otp.verified}">
        <div class="card otp-box">
            <span>Delivery OTP</span>
            <strong>${otp.otp}</strong>
            <small>Give this code to the partner when your goods arrive.</small>
        </div>
    </c:if>
</div>

<script src="${pageContext.request.contextPath}/assets/js/tracking.js"></script>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
