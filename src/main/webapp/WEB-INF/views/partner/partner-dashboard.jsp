<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Partner dashboard"/></jsp:include>

<c:set var="requestCount" value="0"/>
<c:set var="activeCount" value="0"/>
<c:set var="completedCount" value="0"/>
<c:set var="earnings" value="0"/>
<c:forEach var="b" items="${bookings}">
    <c:if test="${b.status == 'MATCHED'}"><c:set var="requestCount" value="${requestCount + 1}"/></c:if>
    <c:if test="${b.status.activeDelivery}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
    <c:if test="${b.status == 'COMPLETED'}">
        <c:set var="completedCount" value="${completedCount + 1}"/>
        <c:set var="earnings" value="${earnings + b.estimatedCost}"/>
    </c:if>
</c:forEach>

<div class="page-head">
    <h1>Hello, <c:out value="${sessionScope.user.name}"/></h1>
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/partner/vehicles">Manage vehicles</a>
</div>

<div class="stats">
    <a class="stat" href="${pageContext.request.contextPath}/partner/requests"><strong>${requestCount}</strong><span>New requests</span></a>
    <a class="stat" href="${pageContext.request.contextPath}/partner/delivery"><strong>${activeCount}</strong><span>Active deliveries</span></a>
    <div class="stat"><strong>${completedCount}</strong><span>Completed</span></div>
    <div class="stat"><strong>&#8377;<fmt:formatNumber value="${earnings}" pattern="#,##0"/></strong><span>Earned</span></div>
</div>

<section class="card">
    <h2>My vehicles</h2>
    <c:if test="${empty vehicles}">
        <p class="muted">Add a vehicle to start receiving bookings.</p>
    </c:if>
    <div class="vehicle-grid">
        <c:forEach var="v" items="${vehicles}">
            <div class="vehicle-card">
                <img class="vehicle-icon" src="${pageContext.request.contextPath}/assets/images/${v.vehicleType}.svg" alt="${v.vehicleType}">
                <div>
                    <strong><c:out value="${v.vehicleNumber}"/></strong>
                    <span class="badge vstatus-${v.status}">${v.status}</span>
                    <div class="load-bar"><div style="width:${v.totalCapacity > 0 ? (v.currentLoad * 100 / v.totalCapacity) : 0}%"></div></div>
                    <small>${v.currentLoad} / ${v.totalCapacity} kg loaded &middot; ${v.availableCapacity} kg free</small>
                </div>
            </div>
        </c:forEach>
    </div>
</section>

<section class="card">
    <h2>All bookings</h2>
    <c:choose>
        <c:when test="${empty bookings}"><p class="muted">No bookings yet.</p></c:when>
        <c:otherwise>
            <div class="table-wrap">
            <table>
                <thead><tr><th>#</th><th>Customer</th><th>Product</th><th>From &rarr; To</th><th>Vehicle</th><th>Status</th><th></th></tr></thead>
                <tbody>
                <c:forEach var="b" items="${bookings}">
                    <tr>
                        <td>${b.id}</td>
                        <td><c:out value="${b.customerName}"/></td>
                        <td><c:out value="${b.productName}"/> (${b.weight} kg)</td>
                        <td><c:out value="${b.pickupAddress}"/> &rarr; <c:out value="${b.destinationAddress}"/></td>
                        <td><c:out value="${b.vehicleNumber}"/></td>
                        <td><span class="badge status-${b.status}">${b.status.label}</span></td>
                        <td>
                            <c:choose>
                                <c:when test="${b.status == 'MATCHED'}"><a href="${pageContext.request.contextPath}/partner/requests">Respond</a></c:when>
                                <c:when test="${b.status.activeDelivery}"><a href="${pageContext.request.contextPath}/partner/delivery?id=${b.id}">Open</a></c:when>
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
