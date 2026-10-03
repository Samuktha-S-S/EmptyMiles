<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- mode = all (My Shipments), open (Find Vehicles: shipments waiting for a vehicle), track (Track Delivery) --%>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="${mode == 'open' ? 'Find Vehicles' : (mode == 'track' ? 'Track Delivery' : 'My Shipments')}"/>
    <jsp:param name="nav" value="${mode == 'open' ? 'find' : (mode == 'track' ? 'track' : 'shipments')}"/>
</jsp:include>

<c:choose>
<%-- ===== Find Vehicles: pick a shipment to search for ===== --%>
<c:when test="${mode == 'open'}">
    <div class="page-head">
        <div>
            <h1>Find Vehicles</h1>
            <p>Choose a shipment and we'll match it with vehicles that have space and are heading your way.</p>
        </div>
        <div class="actions"><a class="btn btn-primary" href="${ctx}/customer/shipment/new"><svg class="i"><use href="${ico}#plus"/></svg><span>Create Shipment</span></a></div>
    </div>
    <c:set var="openCount" value="0"/>
    <section class="card card-flush">
        <c:forEach var="s" items="${shipments}">
            <c:if test="${s.openForBooking}">
                <c:set var="openCount" value="${openCount + 1}"/>
                <a class="list-card" data-loading href="${ctx}/customer/matches?shipmentId=${s.id}">
                    <span class="lc-icon"><svg class="i"><use href="${ico}#package"/></svg></span>
                    <span class="lc-main">
                        <span class="lc-title"><c:out value="${s.productName}"/> &times; ${s.quantity} &middot; <fmt:formatNumber value="${s.weight}" maxFractionDigits="2"/> kg</span>
                        <span class="lc-sub" style="display:block"><c:out value="${s.pickupAddress}"/> &rarr; <c:out value="${s.destinationAddress}"/></span>
                    </span>
                    <span class="lc-right">
                        <span class="small subtle nowrap">Created ${s.createdAt.format(df)}</span>
                        <span class="btn btn-sm btn-primary"><svg class="i"><use href="${ico}#search"/></svg><span>Find Vehicles</span></span>
                    </span>
                </a>
            </c:if>
        </c:forEach>
        <c:if test="${openCount == 0}">
            <div class="empty">
                <div class="empty-icon"><svg class="i"><use href="${ico}#truck"/></svg></div>
                <h3>No shipments waiting for a vehicle</h3>
                <p>Every shipment already has a booking. Create a new shipment to search for matching vehicles.</p>
                <a class="btn btn-primary" href="${ctx}/customer/shipment/new"><svg class="i"><use href="${ico}#plus"/></svg><span>Create Shipment</span></a>
            </div>
        </c:if>
    </section>
</c:when>

<%-- ===== Track Delivery: bookings with a partner ===== --%>
<c:when test="${mode == 'track'}">
    <div class="page-head">
        <div>
            <h1>Track Delivery</h1>
            <p>Follow your goods from pickup to hand-over.</p>
        </div>
    </div>
    <c:set var="trackCount" value="0"/>
    <section class="card card-flush">
        <c:forEach var="bk" items="${bookings}">
            <c:if test="${bk.status != 'CANCELLED'}">
                <c:set var="trackCount" value="${trackCount + 1}"/>
                <a class="list-card" href="${ctx}/customer/${bk.status == 'MATCHED' ? 'booking' : 'tracking'}?id=${bk.id}">
                    <span class="lc-icon"><svg class="i"><use href="${ico}#${fn:toLowerCase(bk.vehicleType)}"/></svg></span>
                    <span class="lc-main">
                        <span class="lc-title">Shipment #${bk.shipmentId} &middot; <c:out value="${bk.productName}"/></span>
                        <span class="lc-sub" style="display:block"><c:out value="${bk.pickupAddress}"/> &rarr; <c:out value="${bk.destinationAddress}"/></span>
                    </span>
                    <span class="lc-right">
                        <span class="badge tone-${bk.status.tone}" title="${bk.status.label}">${bk.status.stage}</span>
                        <svg class="i"><use href="${ico}#chevron-right"/></svg>
                    </span>
                </a>
            </c:if>
        </c:forEach>
        <c:if test="${trackCount == 0}">
            <div class="empty">
                <div class="empty-icon"><svg class="i"><use href="${ico}#pin"/></svg></div>
                <h3>No active deliveries</h3>
                <p>Once you book a vehicle for a shipment, you can follow it here.</p>
                <a class="btn btn-primary" href="${ctx}/customer/find-vehicles"><svg class="i"><use href="${ico}#search"/></svg><span>Find Vehicles</span></a>
            </div>
        </c:if>
    </section>
</c:when>

<%-- ===== My Shipments: everything, with filter tabs ===== --%>
<c:otherwise>
    <c:set var="nPending" value="0"/><c:set var="nActive" value="0"/><c:set var="nDone" value="0"/>
    <c:forEach var="s" items="${shipments}">
        <c:set var="st" value="${s.status.stage}"/>
        <c:choose>
            <c:when test="${st == 'Pending' or st == 'Matched'}"><c:set var="nPending" value="${nPending + 1}"/></c:when>
            <c:when test="${st == 'Confirmed' or st == 'In Transit'}"><c:set var="nActive" value="${nActive + 1}"/></c:when>
            <c:otherwise><c:set var="nDone" value="${nDone + 1}"/></c:otherwise>
        </c:choose>
    </c:forEach>
    <div class="page-head">
        <div>
            <h1>My Shipments</h1>
            <p>Every shipment you've created and where it is now.</p>
        </div>
        <div class="actions"><a class="btn btn-primary" href="${ctx}/customer/shipment/new"><svg class="i"><use href="${ico}#plus"/></svg><span>Create Shipment</span></a></div>
    </div>
    <section class="card card-flush">
        <c:choose>
            <c:when test="${empty shipments}">
                <div class="empty">
                    <div class="empty-icon"><svg class="i"><use href="${ico}#boxes"/></svg></div>
                    <h3>No shipments yet</h3>
                    <p>Create a shipment to get matched with a vehicle heading your way.</p>
                    <a class="btn btn-primary" href="${ctx}/customer/shipment/new"><svg class="i"><use href="${ico}#plus"/></svg><span>Create Shipment</span></a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="tabs" data-filter-group="shipmentRows" role="tablist">
                    <button type="button" class="tab is-active" data-filter="all">All<span class="n">${fn:length(shipments)}</span></button>
                    <button type="button" class="tab" data-filter="pending">Pending<span class="n">${nPending}</span></button>
                    <button type="button" class="tab" data-filter="active">On the way<span class="n">${nActive}</span></button>
                    <button type="button" class="tab" data-filter="done">Delivered<span class="n">${nDone}</span></button>
                </div>
                <div class="table-wrap">
                    <table class="table table-cards">
                        <thead><tr><th>Product</th><th>Qty</th><th>Weight</th><th>Pickup</th><th>Destination</th><th>Created</th><th>Status</th><th></th></tr></thead>
                        <tbody id="shipmentRows">
                        <c:forEach var="s" items="${shipments}">
                            <%@ include file="shipment-row.jspf" %>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
                <div class="empty empty-compact" id="shipmentRowsEmpty" hidden>
                    <p>No shipments in this group.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
