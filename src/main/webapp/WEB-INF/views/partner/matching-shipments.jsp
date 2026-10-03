<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Matching Shipments"/>
    <jsp:param name="nav" value="matching"/>
</jsp:include>

<div class="page-head">
    <div>
        <h1>Matching Shipments</h1>
        <p>Shipments still looking for a vehicle that yours can carry right now. The customer picks the vehicle; their request then appears in Booking Requests.</p>
    </div>
    <div class="actions">
        <a class="btn btn-outline" data-loading href="${ctx}/partner/matching-shipments"><svg class="i"><use href="${ico}#refresh"/></svg><span>Refresh</span></a>
    </div>
</div>

<c:set var="anyAvailable" value="false"/>
<c:forEach var="v" items="${vehicles}"><c:if test="${v.status == 'AVAILABLE' and v.hasLocation()}"><c:set var="anyAvailable" value="true"/></c:if></c:forEach>

<c:choose>
    <c:when test="${not anyAvailable}">
        <section class="card">
            <div class="empty">
                <div class="empty-icon warn"><svg class="i"><use href="${ico}#power"/></svg></div>
                <h3>Go available to see matching shipments</h3>
                <p>Matching only considers vehicles that are available and have shared their location.</p>
                <a class="btn btn-primary" href="${ctx}/partner/vehicles"><span>Go to My Vehicle</span></a>
            </div>
        </section>
    </c:when>
    <c:when test="${empty matches}">
        <section class="card">
            <div class="empty">
                <div class="empty-icon"><svg class="i"><use href="${ico}#search"/></svg></div>
                <h3>No matching shipments right now</h3>
                <p>No open shipment fits your free capacity, pickup range and route at the moment. Check again later.</p>
            </div>
        </section>
    </c:when>
    <c:otherwise>
        <section class="card card-flush">
            <div class="table-wrap">
                <table class="table table-cards">
                    <thead><tr><th>Shipment</th><th>Weight</th><th>Pickup</th><th>Destination</th><th>Distance to pickup</th><th>Your vehicle</th><th>Match score</th></tr></thead>
                    <tbody>
                    <c:forEach var="sm" items="${matches}">
                        <tr>
                            <td data-label="Shipment"><div class="cell-main"><c:out value="${sm.shipment.productName}"/></div>
                                <div class="cell-sub">#${sm.shipment.id} &middot; ${sm.shipment.createdAt.format(df)}<c:if test="${not empty sm.shipment.pickupDate}"> &middot; pickup ${sm.shipment.pickupDate.format(df)}</c:if></div></td>
                            <td data-label="Weight" class="mono nowrap"><fmt:formatNumber value="${sm.shipment.weight}" maxFractionDigits="2"/> kg</td>
                            <td data-label="Pickup" class="cell-place"><c:out value="${sm.shipment.pickupAddress}"/></td>
                            <td data-label="Destination" class="cell-place"><c:out value="${sm.shipment.destinationAddress}"/></td>
                            <td data-label="Distance to pickup" class="mono"><fmt:formatNumber value="${sm.match.distanceToPickupKm}" maxFractionDigits="1"/> km</td>
                            <td data-label="Your vehicle"><span class="reg-plate"><c:out value="${sm.match.vehicle.vehicleNumber}"/></span></td>
                            <td data-label="Match score"><strong><fmt:formatNumber value="${sm.match.matchScore}" minFractionDigits="1" maxFractionDigits="1"/></strong><span class="subtle"> / 100</span></td>
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </section>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
