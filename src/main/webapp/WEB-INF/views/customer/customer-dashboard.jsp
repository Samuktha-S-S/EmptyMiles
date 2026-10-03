<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Dashboard"/>
    <jsp:param name="nav" value="dashboard"/>
</jsp:include>

<%-- Summary numbers, counted from the customer's real shipments --%>
<c:set var="activeCount" value="0"/>
<c:set var="pendingCount" value="0"/>
<c:set var="transitCount" value="0"/>
<c:set var="deliveredCount" value="0"/>
<c:forEach var="s" items="${shipments}">
    <c:set var="st" value="${s.status.stage}"/>
    <c:if test="${st != 'Delivered' and st != 'Completed' and st != 'Cancelled'}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
    <c:if test="${st == 'Pending' or st == 'Matched'}"><c:set var="pendingCount" value="${pendingCount + 1}"/></c:if>
    <c:if test="${st == 'In Transit'}"><c:set var="transitCount" value="${transitCount + 1}"/></c:if>
    <c:if test="${st == 'Delivered' or st == 'Completed'}"><c:set var="deliveredCount" value="${deliveredCount + 1}"/></c:if>
</c:forEach>

<div class="page-head">
    <div>
        <h1><span data-greeting>Hello</span>, <c:out value="${fn:substringBefore(sessionScope.user.name.concat(' '), ' ')}"/> &#128075;</h1>
        <p>Here's your shipment overview.</p>
    </div>
    <div class="actions">
        <a class="btn btn-primary btn-lg" href="${ctx}/customer/shipment/new"><svg class="i"><use href="${ico}#plus"/></svg><span>Create Shipment</span></a>
    </div>
</div>

<div class="stats">
    <a class="stat" href="${ctx}/customer/shipments">
        <span class="stat-icon ic-navy"><svg class="i"><use href="${ico}#boxes"/></svg></span>
        <div><div class="stat-value">${activeCount}</div><div class="stat-label">Active Shipments</div><div class="stat-sub">Not delivered yet</div></div>
    </a>
    <a class="stat" href="${ctx}/customer/find-vehicles">
        <span class="stat-icon ic-amber"><svg class="i"><use href="${ico}#clock"/></svg></span>
        <div><div class="stat-value">${pendingCount}</div><div class="stat-label">Pending Bookings</div><div class="stat-sub">Awaiting a vehicle or partner</div></div>
    </a>
    <a class="stat" href="${ctx}/customer/track">
        <span class="stat-icon ic-teal"><svg class="i"><use href="${ico}#truck"/></svg></span>
        <div><div class="stat-value">${transitCount}</div><div class="stat-label">In Transit</div><div class="stat-sub">Picked up and on the way</div></div>
    </a>
    <a class="stat" href="${ctx}/customer/shipments">
        <span class="stat-icon ic-green"><svg class="i"><use href="${ico}#check-circle"/></svg></span>
        <div><div class="stat-value">${deliveredCount}</div><div class="stat-label">Delivered</div><div class="stat-sub">OTP-verified hand-overs</div></div>
    </a>
</div>

<%-- Most recent booking that is still moving, if any --%>
<c:set var="live" value="${null}"/>
<c:forEach var="bk" items="${bookings}">
    <c:if test="${empty live and (bk.status == 'MATCHED' or bk.status.activeDelivery)}"><c:set var="live" value="${bk}"/></c:if>
</c:forEach>
<c:if test="${not empty live}">
    <section class="card spotlight" style="margin-bottom:24px">
        <div>
            <div class="row-flex">
                <span class="section-label" style="margin:0">Current delivery</span>
                <span class="badge tone-${live.status.tone}">${live.status.stage}</span>
            </div>
            <div style="margin-top:8px;font-weight:650;font-size:16px"><c:out value="${live.productName}"/>
                <span class="subtle" style="font-weight:500">&middot; <fmt:formatNumber value="${live.weight}" maxFractionDigits="2"/> kg &middot; ${fn:toLowerCase(live.vehicleType)} <c:out value="${live.vehicleNumber}"/></span></div>
            <div class="route-inline muted" style="margin-top:4px;font-weight:500">
                <c:out value="${live.pickupAddress}"/> <svg class="i i-sm"><use href="${ico}#arrow-right"/></svg> <c:out value="${live.destinationAddress}"/>
            </div>
            <div class="hprogress" title="${live.status.label}">
                <c:forEach begin="2" end="10" var="n"><span class="${n <= live.status.ordinal() ? 'on' : ''}"></span></c:forEach>
            </div>
            <div class="small subtle" style="margin-top:6px">${live.status.label}</div>
        </div>
        <c:choose>
            <c:when test="${live.status == 'MATCHED'}">
                <a class="btn btn-outline" href="${ctx}/customer/booking?id=${live.id}"><span>View booking</span></a>
            </c:when>
            <c:otherwise>
                <a class="btn btn-navy" href="${ctx}/customer/tracking?id=${live.id}"><svg class="i"><use href="${ico}#pin"/></svg><span>Track delivery</span></a>
            </c:otherwise>
        </c:choose>
    </section>
</c:if>

<section class="card card-flush">
    <div class="card-head">
        <h2>Recent Shipments</h2>
        <span class="sub">${fn:length(shipments)} total</span>
        <c:if test="${not empty shipments}"><a class="push-right btn btn-sm btn-ghost" href="${ctx}/customer/shipments"><span>View all</span><svg class="i"><use href="${ico}#chevron-right"/></svg></a></c:if>
    </div>
    <c:choose>
        <c:when test="${empty shipments}">
            <div class="empty">
                <div class="empty-icon"><svg class="i"><use href="${ico}#package"/></svg></div>
                <h3>No shipments yet</h3>
                <p>Create your first shipment and we'll find vehicles with free space heading your way.</p>
                <a class="btn btn-primary" href="${ctx}/customer/shipment/new"><svg class="i"><use href="${ico}#plus"/></svg><span>Create Shipment</span></a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="table-wrap">
                <table class="table table-cards">
                    <thead><tr><th>Product</th><th>Qty</th><th>Weight</th><th>Pickup</th><th>Destination</th><th>Created</th><th>Status</th><th></th></tr></thead>
                    <tbody>
                    <c:forEach var="s" items="${shipments}" end="5">
                        <%@ include file="shipment-row.jspf" %>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
