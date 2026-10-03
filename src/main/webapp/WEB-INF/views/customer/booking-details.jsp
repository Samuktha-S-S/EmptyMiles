<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Booking #${booking.id}"/>
    <jsp:param name="nav" value="track"/>
</jsp:include>
<c:set var="vt" value="${fn:toLowerCase(booking.vehicleType)}"/>

<a class="back-link" href="${ctx}/customer/dashboard"><svg class="i i-sm"><use href="${ico}#arrow-left"/></svg>Dashboard</a>
<div class="page-head">
    <div>
        <div class="row-flex"><h1>Booking #${booking.id}</h1><span class="badge tone-${booking.status.tone}">${booking.status.stage}</span></div>
        <p>Shipment #${shipment.id} &middot; booked ${booking.createdAt.format(dtf)}</p>
    </div>
    <div class="actions">
        <c:if test="${booking.status != 'CANCELLED' and booking.status != 'MATCHED'}">
            <a class="btn btn-navy" href="${ctx}/customer/tracking?id=${booking.id}"><svg class="i"><use href="${ico}#pin"/></svg><span>Track delivery</span></a>
        </c:if>
    </div>
</div>

<div class="grid-main-side">
    <div class="stack">
        <c:choose>
            <c:when test="${booking.status == 'MATCHED'}">
                <section class="card">
                    <div class="success-hero">
                        <div class="check"><svg class="i"><use href="${ico}#check"/></svg></div>
                        <h2>Booking Requested &#10003;</h2>
                        <p>We've sent your request to <strong><c:out value="${booking.partnerName}"/></strong>.
                            You'll see your delivery OTP here as soon as they accept.</p>
                        <div class="button-row" style="justify-content:center;margin-top:16px">
                            <a class="btn btn-outline" href="${ctx}/customer/booking?id=${booking.id}"><svg class="i"><use href="${ico}#refresh"/></svg><span>Refresh status</span></a>
                        </div>
                    </div>
                </section>
            </c:when>
            <c:when test="${booking.status == 'CANCELLED'}">
                <section class="card">
                    <div class="empty">
                        <div class="empty-icon warn"><svg class="i"><use href="${ico}#alert"/></svg></div>
                        <h2>The partner couldn't take this booking</h2>
                        <p>Your shipment is open again. Pick another vehicle that fits.</p>
                        <a class="btn btn-primary" data-loading href="${ctx}/customer/matches?shipmentId=${booking.shipmentId}"><svg class="i"><use href="${ico}#search"/></svg><span>Choose another vehicle</span></a>
                    </div>
                </section>
            </c:when>
        </c:choose>

        <c:if test="${not empty otp and not otp.verified and booking.status != 'CANCELLED'}">
            <section class="otp-display">
                <div>
                    <div class="k">Delivery OTP</div>
                    <p>Share this code with the partner only when your goods reach the destination.</p>
                </div>
                <div class="digits push-right">
                    <c:forEach var="i" begin="0" end="${fn:length(otp.otp) - 1}"><span>${fn:substring(otp.otp, i, i + 1)}</span></c:forEach>
                </div>
            </section>
        </c:if>
        <c:if test="${not empty otp and otp.verified}">
            <div class="alert alert-success" style="margin:0"><svg class="i"><use href="${ico}#shield"/></svg>
                <span>Delivery verified with OTP<c:if test="${not empty booking.deliveryTime}"> on ${booking.deliveryTime.format(dtf)}</c:if>.</span></div>
        </c:if>

        <section class="card">
            <div class="card-head"><h2>Shipment</h2></div>
            <dl class="kv">
                <dt>Product</dt><dd><c:out value="${shipment.productName}"/> (<c:out value="${shipment.productType}"/>) &times; ${shipment.quantity}</dd>
                <dt>Weight</dt><dd><fmt:formatNumber value="${shipment.weight}" maxFractionDigits="2"/> kg</dd>
                <c:if test="${shipment.hasDimensions()}">
                    <dt>Dimensions</dt><dd><fmt:formatNumber value="${shipment.lengthCm}" maxFractionDigits="1"/> &times; <fmt:formatNumber value="${shipment.widthCm}" maxFractionDigits="1"/> &times; <fmt:formatNumber value="${shipment.heightCm}" maxFractionDigits="1"/> cm</dd>
                </c:if>
                <c:if test="${not empty shipment.specialRequirements}"><dt>Requirements</dt><dd><c:out value="${shipment.specialRequirements}"/></dd></c:if>
                <c:if test="${not empty shipment.pickupDate}"><dt>Pickup date</dt><dd>${shipment.pickupDate.format(df)}<c:if test="${not empty shipment.pickupTimeSlot}">, <c:out value="${shipment.pickupTimeSlot}"/></c:if></dd></c:if>
                <c:if test="${not empty shipment.specialInstructions}"><dt>Instructions</dt><dd><c:out value="${shipment.specialInstructions}"/></dd></c:if>
            </dl>
            <div class="route" style="margin-top:18px">
                <div class="route-stop"><span class="route-dot"></span><div><div class="k">Pickup</div><div class="v"><c:out value="${shipment.pickupAddress}"/></div></div></div>
                <div class="route-stop to"><span class="route-dot"></span><div><div class="k">Destination</div><div class="v"><c:out value="${shipment.destinationAddress}"/></div></div></div>
            </div>
        </section>
    </div>

    <div class="stack">
        <section class="card">
            <div class="card-head"><h2>Travel partner</h2></div>
            <div class="row-flex" style="margin-bottom:16px">
                <span class="vtype-icon"><svg class="i"><use href="${ico}#${vt}"/></svg></span>
                <div>
                    <div style="font-weight:650;text-transform:capitalize">${vt}</div>
                    <span class="reg-plate"><c:out value="${booking.vehicleNumber}"/></span>
                </div>
            </div>
            <dl class="summary-list">
                <div><dt>Partner</dt><dd><c:out value="${booking.partnerName}"/></dd></div>
                <div><dt>Phone</dt><dd><a href="tel:<c:out value='${booking.partnerPhone}'/>"><c:out value="${booking.partnerPhone}"/></a></dd></div>
                <div><dt>Match score</dt><dd><fmt:formatNumber value="${booking.matchScore}" minFractionDigits="1" maxFractionDigits="1"/> / 100</dd></div>
                <div><dt>Estimated cost</dt><dd>&#8377;<fmt:formatNumber value="${booking.estimatedCost}" pattern="#,##0"/></dd></div>
                <c:if test="${not empty booking.pickupTime}"><div><dt>Picked up</dt><dd>${booking.pickupTime.format(dtf)}</dd></div></c:if>
                <c:if test="${not empty booking.deliveryTime}"><div><dt>Delivered</dt><dd>${booking.deliveryTime.format(dtf)}</dd></div></c:if>
            </dl>
        </section>
    </div>
</div>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
