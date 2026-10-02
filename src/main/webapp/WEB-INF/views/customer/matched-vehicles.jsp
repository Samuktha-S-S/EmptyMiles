<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Matched vehicles"/></jsp:include>

<h1>Matched vehicles</h1>
<div class="card summary">
    <div><span class="muted">Shipment #${shipment.id}</span><br>
        <strong><c:out value="${shipment.productName}"/></strong> &times; ${shipment.quantity}, ${shipment.weight} kg</div>
    <div><span class="muted">From</span><br><c:out value="${shipment.pickupAddress}"/></div>
    <div><span class="muted">To</span><br><c:out value="${shipment.destinationAddress}"/></div>
</div>

<c:choose>
    <c:when test="${empty matches}">
        <div class="card center">
            <h2>No suitable vehicle right now</h2>
            <p class="muted">No available vehicle nearby has enough free capacity on a compatible route.
                Try again in a few minutes.</p>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/customer/matches?shipmentId=${shipment.id}">Search again</a>
        </div>
    </c:when>
    <c:otherwise>
        <p class="muted">${matches.size()} vehicle(s) found, best match first.
            Score = 40% distance to pickup + 35% route fit + 25% capacity use.</p>
        <c:forEach var="m" items="${matches}" varStatus="loop">
            <div class="card match ${loop.first ? 'best' : ''}">
                <div class="match-rank">#${loop.index + 1}</div>
                <img class="vehicle-icon" src="${pageContext.request.contextPath}/assets/images/${m.vehicle.vehicleType}.svg" alt="${m.vehicle.vehicleType}">
                <div class="match-info">
                    <h3>${m.vehicle.vehicleType} &middot; <c:out value="${m.vehicle.vehicleNumber}"/>
                        <c:if test="${loop.first}"><span class="badge best-badge">Best match</span></c:if></h3>
                    <p>Partner: <c:out value="${m.vehicle.partnerName}"/></p>
                    <ul class="facts">
                        <li><strong>${m.distanceToPickupKm} km</strong> to pickup</li>
                        <li><strong>${m.vehicle.availableCapacity} kg</strong> free of ${m.vehicle.totalCapacity} kg</li>
                        <li>
                            <c:choose>
                                <c:when test="${m.onRoute}">Heading to <c:out value="${m.vehicle.destination}"/> (detour ${m.detourKm} km)</c:when>
                                <c:otherwise>No fixed route</c:otherwise>
                            </c:choose>
                        </li>
                        <li>Trip ${m.tripDistanceKm} km</li>
                    </ul>
                    <div class="score-bar"><div style="width:${m.matchScore}%"></div></div>
                    <small>Match score ${m.matchScore} / 100</small>
                </div>
                <div class="match-action">
                    <div class="price">&#8377;<fmt:formatNumber value="${m.estimatedCost}" pattern="#,##0"/></div>
                    <form method="post" action="${pageContext.request.contextPath}/customer/book">
                        <input type="hidden" name="shipmentId" value="${shipment.id}">
                        <input type="hidden" name="vehicleId" value="${m.vehicle.id}">
                        <button type="submit" class="btn btn-primary">Select</button>
                    </form>
                </div>
            </div>
        </c:forEach>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
