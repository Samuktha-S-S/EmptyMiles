<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Partner dashboard"/>
    <jsp:param name="nav" value="dashboard"/>
</jsp:include>

<%-- Summary numbers, counted from the partner's real bookings and vehicles --%>
<c:set var="requestCount" value="0"/>
<c:set var="activeCount" value="0"/>
<c:set var="completedCount" value="0"/>
<c:set var="earnings" value="0"/>
<c:set var="freeCapacity" value="0"/>
<c:forEach var="b" items="${bookings}">
    <c:if test="${b.status == 'MATCHED'}"><c:set var="requestCount" value="${requestCount + 1}"/></c:if>
    <c:if test="${b.status.activeDelivery}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
    <c:if test="${b.status == 'COMPLETED'}">
        <c:set var="completedCount" value="${completedCount + 1}"/>
        <c:set var="earnings" value="${earnings + b.estimatedCost}"/>
    </c:if>
</c:forEach>
<c:forEach var="v" items="${vehicles}">
    <c:set var="freeCapacity" value="${freeCapacity + v.availableCapacity}"/>
</c:forEach>

<div class="page-head">
    <div>
        <h1><span data-greeting>Hello</span>, <c:out value="${fn:substringBefore(sessionScope.user.name.concat(' '), ' ')}"/> &#128075;</h1>
        <p>Here's your vehicle and delivery overview.</p>
    </div>
    <div class="actions">
        <a class="btn btn-outline" href="${ctx}/partner/location"><svg class="i"><use href="${ico}#crosshair"/></svg><span>Update location</span></a>
        <a class="btn btn-primary" href="${ctx}/partner/requests"><svg class="i"><use href="${ico}#inbox"/></svg><span>View requests</span></a>
    </div>
</div>

<div class="stats">
    <a class="stat" href="${ctx}/partner/vehicles">
        <span class="stat-icon ic-teal"><svg class="i"><use href="${ico}#gauge"/></svg></span>
        <div><div class="stat-value"><fmt:formatNumber value="${freeCapacity}" maxFractionDigits="1"/><small>kg</small></div><div class="stat-label">Available Capacity</div>
            <div class="stat-sub">Across ${fn:length(vehicles)} vehicle${fn:length(vehicles) == 1 ? '' : 's'}</div></div>
    </a>
    <a class="stat" href="${ctx}/partner/requests">
        <span class="stat-icon ic-amber"><svg class="i"><use href="${ico}#inbox"/></svg></span>
        <div><div class="stat-value">${requestCount}</div><div class="stat-label">Pending Requests</div><div class="stat-sub">Waiting for your answer</div></div>
    </a>
    <a class="stat" href="${ctx}/partner/delivery">
        <span class="stat-icon ic-navy"><svg class="i"><use href="${ico}#route"/></svg></span>
        <div><div class="stat-value">${activeCount}</div><div class="stat-label">Active Deliveries</div><div class="stat-sub">Accepted, not completed</div></div>
    </a>
    <div class="stat">
        <span class="stat-icon ic-green"><svg class="i"><use href="${ico}#check-circle"/></svg></span>
        <div><div class="stat-value">${completedCount}</div><div class="stat-label">Completed Deliveries</div>
            <div class="stat-sub">&#8377;<fmt:formatNumber value="${earnings}" pattern="#,##0"/> earned</div></div>
    </div>
</div>

<c:if test="${requestCount > 0}">
    <div class="alert alert-warning">
        <svg class="i"><use href="${ico}#inbox"/></svg>
        <span>You have ${requestCount} booking request${requestCount == 1 ? '' : 's'} waiting. <a href="${ctx}/partner/requests"><strong>Review now</strong></a></span>
    </div>
</c:if>

<div class="grid-main-side">
    <section class="card">
        <div class="card-head">
            <h2>${fn:length(vehicles) > 1 ? 'My vehicles' : 'My vehicle'}</h2>
            <a class="push-right btn btn-sm btn-ghost" href="${ctx}/partner/vehicles"><span>Manage</span><svg class="i"><use href="${ico}#chevron-right"/></svg></a>
        </div>
        <c:choose>
            <c:when test="${empty vehicles}">
                <div class="empty empty-compact">
                    <div class="empty-icon"><svg class="i"><use href="${ico}#truck"/></svg></div>
                    <h3>No vehicle yet</h3>
                    <p>Add your bike, auto or truck to start receiving shipments that fit your route.</p>
                    <a class="btn btn-primary" href="${ctx}/partner/vehicles#add"><svg class="i"><use href="${ico}#plus"/></svg><span>Add vehicle</span></a>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="v" items="${vehicles}">
                    <%@ include file="vehicle-overview.jspf" %>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </section>

    <section class="card card-flush">
        <div class="card-head"><h2>Active deliveries</h2></div>
        <c:set var="shown" value="0"/>
        <c:forEach var="b" items="${bookings}">
            <c:if test="${b.status.activeDelivery}">
                <c:set var="shown" value="${shown + 1}"/>
                <a class="list-card" href="${ctx}/partner/delivery?id=${b.id}">
                    <span class="lc-main">
                        <span class="lc-title"><c:out value="${b.productName}"/> &middot; <fmt:formatNumber value="${b.weight}" maxFractionDigits="2"/> kg</span>
                        <span class="lc-sub" style="display:block"><c:out value="${b.destinationAddress}"/></span>
                        <span class="badge tone-${b.status.tone}" style="margin-top:6px">${b.status.stepLabel}</span>
                    </span>
                    <svg class="i"><use href="${ico}#chevron-right"/></svg>
                </a>
            </c:if>
        </c:forEach>
        <c:if test="${shown == 0}">
            <div class="empty empty-compact">
                <div class="empty-icon"><svg class="i"><use href="${ico}#route"/></svg></div>
                <h3>No active deliveries</h3>
                <p>Accepted requests show up here.</p>
            </div>
        </c:if>
    </section>
</div>

<section class="card card-flush" style="margin-top:20px">
    <div class="card-head"><h2>Recent bookings</h2><span class="sub">${fn:length(bookings)} total</span></div>
    <c:choose>
        <c:when test="${empty bookings}">
            <div class="empty">
                <div class="empty-icon"><svg class="i"><use href="${ico}#inbox"/></svg></div>
                <h3>No bookings yet</h3>
                <p>Go available and keep your location up to date so customers' shipments can match your vehicle.</p>
                <a class="btn btn-primary" href="${ctx}/partner/matching-shipments"><svg class="i"><use href="${ico}#search"/></svg><span>See matching shipments</span></a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="table-wrap">
                <table class="table table-cards">
                    <thead><tr><th>Booking</th><th>Customer</th><th>Weight</th><th>Pickup</th><th>Destination</th><th>Vehicle</th><th>Status</th><th></th></tr></thead>
                    <tbody>
                    <c:forEach var="b" items="${bookings}" end="9">
                        <tr>
                            <td data-label="Booking"><div class="cell-main"><c:out value="${b.productName}"/></div><div class="cell-sub">#${b.id} &middot; ${b.createdAt.format(df)}</div></td>
                            <td data-label="Customer"><c:out value="${b.customerName}"/></td>
                            <td data-label="Weight" class="mono nowrap"><fmt:formatNumber value="${b.weight}" maxFractionDigits="2"/> kg</td>
                            <td data-label="Pickup" class="cell-place"><c:out value="${b.pickupAddress}"/></td>
                            <td data-label="Destination" class="cell-place"><c:out value="${b.destinationAddress}"/></td>
                            <td data-label="Vehicle"><span class="reg-plate"><c:out value="${b.vehicleNumber}"/></span></td>
                            <td data-label="Status"><span class="badge tone-${b.status.tone}" title="${b.status.label}">${b.status.stepLabel}</span></td>
                            <td class="actions">
                                <c:choose>
                                    <c:when test="${b.status == 'MATCHED'}"><a class="btn btn-sm btn-primary" href="${ctx}/partner/requests"><span>Respond</span></a></c:when>
                                    <c:when test="${b.status.activeDelivery}"><a class="btn btn-sm btn-navy" href="${ctx}/partner/delivery?id=${b.id}"><span>Open</span></a></c:when>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
