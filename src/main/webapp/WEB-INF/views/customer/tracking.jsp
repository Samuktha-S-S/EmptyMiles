<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Track delivery"/>
    <jsp:param name="nav" value="track"/>
</jsp:include>
<c:set var="vt" value="${fn:toLowerCase(booking.vehicleType)}"/>
<c:set var="hasLocation" value="${not empty tracking.latitude}"/>

<a class="back-link" href="${ctx}/customer/track"><svg class="i i-sm"><use href="${ico}#arrow-left"/></svg>All deliveries</a>
<div class="page-head">
    <div class="track-hero">
        <span class="pk"><svg class="i"><use href="${ico}#package"/></svg></span>
        <div>
            <div class="eyebrow">Shipment #${shipment.id}</div>
            <h1><c:out value="${shipment.productName}"/></h1>
            <p><fmt:formatNumber value="${shipment.weight}" maxFractionDigits="2"/> kg &middot; ${shipment.quantity} item${shipment.quantity == 1 ? '' : 's'} &middot; Booking #${booking.id}</p>
        </div>
    </div>
    <div class="actions">
        <span class="badge tone-${tracking.status.tone}" id="statusBadge" style="height:30px;font-size:13px">${tracking.status.stage}</span>
        <a class="btn btn-outline" href="${ctx}/customer/booking?id=${booking.id}"><span>Booking details</span></a>
    </div>
</div>

<div id="tracking" data-booking-id="${booking.id}">

<c:if test="${tracking.status == 'CANCELLED'}">
    <div class="alert alert-warning"><svg class="i"><use href="${ico}#alert"/></svg>
        <span>This booking was cancelled by the partner. <a href="${ctx}/customer/matches?shipmentId=${booking.shipmentId}">Choose another vehicle</a>.</span></div>
</c:if>

<div class="grid-main-side">
    <div class="stack">
        <section class="card">
            <div class="grid-2" style="align-items:center">
                <div class="route">
                    <div class="route-stop"><span class="route-dot"></span><div><div class="k">From</div><div class="v"><c:out value="${shipment.pickupAddress}"/></div></div></div>
                    <div class="route-stop to"><span class="route-dot"></span><div><div class="k">To</div><div class="v"><c:out value="${shipment.destinationAddress}"/></div></div></div>
                </div>
                <div class="row-flex" style="justify-content:flex-end">
                    <span class="vtype-icon"><svg class="i"><use href="${ico}#${vt}"/></svg></span>
                    <div>
                        <div style="font-weight:650"><c:out value="${booking.partnerName}"/></div>
                        <div class="small subtle" style="text-transform:capitalize">${vt} &middot; <span class="reg-plate"><c:out value="${booking.vehicleNumber}"/></span></div>
                    </div>
                </div>
            </div>
            <div class="route-map" id="trackMap" data-route-map style="height:300px;margin-top:18px"
                 data-pickup="${shipment.pickupLatitude},${shipment.pickupLongitude}" data-pickup-label="<c:out value='${shipment.pickupAddress}'/>"
                 data-dest="${shipment.destinationLatitude},${shipment.destinationLongitude}" data-dest-label="<c:out value='${shipment.destinationAddress}'/>"
                 data-vehicle="${hasLocation ? tracking.latitude.toString().concat(',').concat(tracking.longitude) : ''}"
                 data-vehicle-label="${vt}" data-vehicle-legend="Vehicle"
                 data-vehicle-to-pickup="${tracking.status.ordinal() < 6}"></div>
        </section>

        <section class="card location-card">
            <div class="card-head">
                <h2>Current location</h2>
                <span class="live" id="liveTag" ${hasLocation and not tracking.status.finished ? '' : 'hidden'}>Live</span>
                <a id="mapLink" class="btn btn-sm btn-ghost push-right" target="_blank" rel="noopener"
                   href="https://www.openstreetmap.org/?mlat=${tracking.latitude}&mlon=${tracking.longitude}#map=15/${tracking.latitude}/${tracking.longitude}"
                   ${hasLocation ? '' : 'hidden'}><span>Open in OpenStreetMap</span><svg class="i"><use href="${ico}#external"/></svg></a>
            </div>
            <div id="noLocation" class="empty empty-compact" ${hasLocation ? 'hidden' : ''}>
                <div class="empty-icon"><svg class="i"><use href="${ico}#crosshair"/></svg></div>
                <h3>Location update not available yet.</h3>
                <p>The partner's position appears here once their phone starts sharing it.</p>
            </div>
            <div id="locationData" ${hasLocation ? '' : 'hidden'}>
                <div class="metric-row">
                    <div class="metric"><div class="k">Coordinates</div><div class="v" id="position" style="font-size:15px">${hasLocation ? tracking.latitude.toString().concat(', ').concat(tracking.longitude) : ''}</div></div>
                    <div class="metric"><div class="k">Last updated</div><div class="v" id="lastUpdated" style="font-size:15px">${empty tracking.lastUpdated ? 'Last known vehicle position' : tracking.lastUpdated.format(dtf)}</div></div>
                    <div class="metric"><div class="k">Distance to pickup</div><div class="v" id="toPickup">${empty tracking.distanceToPickupKm ? '-' : tracking.distanceToPickupKm.toString().concat(' km')}</div></div>
                    <div class="metric"><div class="k">Distance to destination</div><div class="v" id="toDestination">${empty tracking.distanceToDestinationKm ? '-' : tracking.distanceToDestinationKm.toString().concat(' km')}</div></div>
                </div>
            </div>
            <c:if test="${not tracking.status.finished}">
                <p class="small subtle" id="refreshNote" style="margin-top:12px"><span class="spinner" style="width:12px;height:12px;border-width:2px"></span> Refreshes automatically every 10 seconds.</p>
            </c:if>
        </section>
    </div>

    <div class="stack">
        <c:if test="${not empty otp and not otp.verified and tracking.status != 'CANCELLED'}">
            <section class="otp-display">
                <div>
                    <div class="k">Delivery OTP</div>
                    <p>Give this code to the partner when your goods arrive.</p>
                </div>
                <div class="digits">
                    <c:forEach var="i" begin="0" end="${fn:length(otp.otp) - 1}"><span>${fn:substring(otp.otp, i, i + 1)}</span></c:forEach>
                </div>
            </section>
        </c:if>

        <section class="card">
            <div class="card-head"><h2>Tracking timeline</h2></div>
            <ol class="timeline" id="timeline">
                <c:forEach var="s" items="${statuses}">
                    <c:if test="${s != 'CANCELLED' and s != 'SEARCHING'}">
                        <li data-status="${s}" data-order="${s.ordinal()}"
                            class="${s.ordinal() < tracking.status.ordinal() or tracking.status == 'COMPLETED' ? 'done' : (s == tracking.status ? 'current' : '')}">
                            <span class="dot"><svg class="i"><use href="${ico}#check"/></svg></span>
                            <div>
                                <div class="t-label">${s.stepLabel}<span class="now">Now</span></div>
                                <div class="t-sub">
                                    <c:choose>
                                        <c:when test="${s == 'REQUESTED'}">${shipment.createdAt.format(dtf)}</c:when>
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
</div>
</div>

<script src="${ctx}/assets/js/route-map.js"></script>
<script src="${ctx}/assets/js/tracking.js"></script>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
