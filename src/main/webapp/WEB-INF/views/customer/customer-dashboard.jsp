<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Customer dashboard"/></jsp:include>

<div class="page-head">
    <h1>Hello, <c:out value="${sessionScope.user.name}"/></h1>
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/customer/shipment/new">+ Send goods</a>
</div>

<section class="card">
    <h2>My bookings</h2>
    <c:choose>
        <c:when test="${empty bookings}">
            <p class="muted">No bookings yet. Create a shipment and pick a vehicle to get started.</p>
        </c:when>
        <c:otherwise>
            <div class="table-wrap">
            <table>
                <thead>
                <tr><th>#</th><th>Product</th><th>From &rarr; To</th><th>Vehicle</th><th>Cost</th><th>Status</th><th></th></tr>
                </thead>
                <tbody>
                <c:forEach var="b" items="${bookings}">
                    <tr>
                        <td>${b.id}</td>
                        <td><c:out value="${b.productName}"/> (${b.weight} kg)</td>
                        <td><c:out value="${b.pickupAddress}"/> &rarr; <c:out value="${b.destinationAddress}"/></td>
                        <td>${b.vehicleType} <c:out value="${b.vehicleNumber}"/></td>
                        <td>&#8377;<fmt:formatNumber value="${b.estimatedCost}" pattern="#,##0"/></td>
                        <td><span class="badge status-${b.status}">${b.status.label}</span></td>
                        <td class="actions">
                            <a href="${pageContext.request.contextPath}/customer/booking?id=${b.id}">Details</a>
                            <c:if test="${b.status != 'CANCELLED'}">
                                <a href="${pageContext.request.contextPath}/customer/tracking?id=${b.id}">Track</a>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
            </div>
        </c:otherwise>
    </c:choose>
</section>

<section class="card">
    <h2>Shipments waiting for a vehicle</h2>
    <c:set var="waiting" value="0"/>
    <div class="table-wrap">
    <table>
        <thead><tr><th>#</th><th>Product</th><th>Weight</th><th>From &rarr; To</th><th>Created</th><th></th></tr></thead>
        <tbody>
        <c:forEach var="s" items="${shipments}">
            <c:if test="${s.openForBooking}">
                <c:set var="waiting" value="${waiting + 1}"/>
                <tr>
                    <td>${s.id}</td>
                    <td><c:out value="${s.productName}"/> &times; ${s.quantity}</td>
                    <td>${s.weight} kg</td>
                    <td><c:out value="${s.pickupAddress}"/> &rarr; <c:out value="${s.destinationAddress}"/></td>
                    <td>${fn:replace(s.createdAt, 'T', ' ')}</td>
                    <td><a class="btn btn-small btn-primary" href="${pageContext.request.contextPath}/customer/matches?shipmentId=${s.id}">Find vehicles</a></td>
                </tr>
            </c:if>
        </c:forEach>
        </tbody>
    </table>
    </div>
    <c:if test="${waiting == 0}"><p class="muted">Nothing waiting.</p></c:if>
</section>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
