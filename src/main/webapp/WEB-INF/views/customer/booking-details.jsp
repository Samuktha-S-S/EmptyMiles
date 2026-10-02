<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Booking details"/></jsp:include>

<div class="page-head">
    <h1>Booking #${booking.id}</h1>
    <span class="badge status-${booking.status}">${booking.status.label}</span>
</div>

<c:if test="${not empty otp and not otp.verified}">
    <div class="card otp-box">
        <span>Delivery OTP</span>
        <strong>${otp.otp}</strong>
        <small>Share this code with the partner only when your goods reach the destination.</small>
    </div>
</c:if>
<c:if test="${booking.status == 'MATCHED'}">
    <div class="alert alert-info">Waiting for the partner to accept your request.</div>
</c:if>
<c:if test="${booking.status == 'CANCELLED'}">
    <div class="alert alert-error">The partner could not take this booking.
        <a href="${pageContext.request.contextPath}/customer/matches?shipmentId=${booking.shipmentId}">Choose another vehicle</a>.</div>
</c:if>

<div class="grid-2">
    <section class="card">
        <h2>Shipment</h2>
        <dl>
            <dt>Product</dt><dd><c:out value="${shipment.productName}"/> (<c:out value="${shipment.productType}"/>) &times; ${shipment.quantity}</dd>
            <dt>Weight</dt><dd>${shipment.weight} kg</dd>
            <dt>Pickup</dt><dd><c:out value="${shipment.pickupAddress}"/></dd>
            <dt>Destination</dt><dd><c:out value="${shipment.destinationAddress}"/></dd>
        </dl>
    </section>
    <section class="card">
        <h2>Delivery partner</h2>
        <dl>
            <dt>Partner</dt><dd><c:out value="${booking.partnerName}"/></dd>
            <dt>Phone</dt><dd><c:out value="${booking.partnerPhone}"/></dd>
            <dt>Vehicle</dt><dd>${booking.vehicleType} <c:out value="${booking.vehicleNumber}"/></dd>
            <dt>Estimated cost</dt><dd>&#8377;<fmt:formatNumber value="${booking.estimatedCost}" pattern="#,##0"/></dd>
            <dt>Match score</dt><dd>${booking.matchScore} / 100</dd>
            <dt>Booked at</dt><dd>${fn:replace(booking.createdAt, 'T', ' ')}</dd>
            <c:if test="${not empty booking.pickupTime}"><dt>Picked up</dt><dd>${fn:replace(booking.pickupTime, 'T', ' ')}</dd></c:if>
            <c:if test="${not empty booking.deliveryTime}"><dt>Delivered</dt><dd>${fn:replace(booking.deliveryTime, 'T', ' ')}</dd></c:if>
        </dl>
    </section>
</div>

<c:if test="${booking.status != 'CANCELLED'}">
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/customer/tracking?id=${booking.id}">Track delivery</a>
</c:if>
<a class="btn btn-outline" href="${pageContext.request.contextPath}/customer/dashboard">Back</a>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
