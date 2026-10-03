<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Left brand panel shared by login and register --%>
<c:set var="ico" value="${pageContext.request.contextPath}/assets/images/icons.svg"/>
<aside class="auth-brand">
    <span class="brand">
        <span class="brand-mark"><svg class="i"><use href="${ico}#route"/></svg></span>
        <span>EMPTY<b>MILES</b></span>
    </span>
    <div class="auth-pitch">
        <h1>Send goods with vehicles <span>already on the road.</span></h1>
        <p>EmptyMiles matches your parcel with bikes, autos and trucks that have free space and are heading your way.</p>
        <ul class="auth-points">
            <li><span class="pi"><svg class="i"><use href="${ico}#gauge"/></svg></span>
                <div><b>Uses spare capacity</b><small>Only vehicles with room for your goods are shown.</small></div></li>
            <li><span class="pi"><svg class="i"><use href="${ico}#route"/></svg></span>
                <div><b>Route-aware matching</b><small>Nearby pickup, compatible route, ranked by match score.</small></div></li>
            <li><span class="pi"><svg class="i"><use href="${ico}#shield"/></svg></span>
                <div><b>Tracked and OTP-verified</b><small>Follow the delivery live and confirm the hand-over with a code.</small></div></li>
        </ul>
    </div>
    <div class="auth-journey">
        Shipment <svg class="i"><use href="${ico}#arrow-right"/></svg>
        Match <svg class="i"><use href="${ico}#arrow-right"/></svg>
        Booking <svg class="i"><use href="${ico}#arrow-right"/></svg>
        Tracking
    </div>
</aside>
