<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Help"/>
    <jsp:param name="nav" value="help"/>
</jsp:include>

<div class="page-head">
    <div>
        <h1>How EmptyMiles works</h1>
        <p>Your goods ride along in the free space of vehicles that are already heading your way.</p>
    </div>
</div>

<section class="card" style="margin-bottom:20px">
    <div class="how-steps">
        <div class="how-step"><div class="n">1</div><h3>Create a shipment</h3><p>Tell us what you're sending, its weight, and the pickup and delivery locations.</p></div>
        <div class="how-step"><div class="n">2</div><h3>Get matched</h3><p>We look for available vehicles with enough free space, close to your pickup and on a compatible route.</p></div>
        <div class="how-step"><div class="n">3</div><h3>Book and track</h3><p>Request the vehicle you like. Once the partner accepts, follow the delivery live.</p></div>
        <div class="how-step"><div class="n">4</div><h3>Confirm with OTP</h3><p>Give the partner your 4-digit code at the destination to confirm the hand-over.</p></div>
    </div>
</section>

<div class="grid-2">
    <section class="card">
        <div class="card-head"><h2>Why a vehicle matches</h2></div>
        <ul class="why">
            <li><svg class="i"><use href="${ico}#check"/></svg><div>Enough capacity<small>Its free space is at least your shipment's weight.</small></div></li>
            <li><svg class="i"><use href="${ico}#check"/></svg><div>Nearby pickup<small>Bikes travel up to 10 km to a pickup, autos 15 km, trucks 40 km.</small></div></li>
            <li><svg class="i"><use href="${ico}#check"/></svg><div>Compatible route<small>If the vehicle is already heading somewhere, your delivery may only add a small detour.</small></div></li>
            <li><svg class="i"><use href="${ico}#check"/></svg><div>Available now<small>The partner has switched the vehicle to Available.</small></div></li>
        </ul>
        <p class="small muted" style="margin-top:14px">The match score (out of 100) favours vehicles that are closer, need a smaller detour, and would fill their free space well.</p>
    </section>
    <section class="card">
        <div class="card-head"><h2>Delivery statuses</h2></div>
        <dl class="summary-list">
            <div><dt><span class="badge tone-pending">Pending</span></dt><dd style="font-weight:500">Waiting for you to pick a vehicle</dd></div>
            <div><dt><span class="badge tone-matched">Matched</span></dt><dd style="font-weight:500">Request sent, waiting for the partner</dd></div>
            <div><dt><span class="badge tone-confirmed">Confirmed</span></dt><dd style="font-weight:500">Partner accepted and is heading to pickup</dd></div>
            <div><dt><span class="badge tone-transit">In Transit</span></dt><dd style="font-weight:500">Picked up and on the way</dd></div>
            <div><dt><span class="badge tone-success">Delivered</span></dt><dd style="font-weight:500">Hand-over confirmed with your OTP</dd></div>
        </dl>
    </section>
</div>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
