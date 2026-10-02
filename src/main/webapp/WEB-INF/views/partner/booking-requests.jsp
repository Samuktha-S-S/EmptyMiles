<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Booking requests"/></jsp:include>

<h1>Booking requests</h1>

<c:choose>
    <c:when test="${empty requests}">
        <div class="card center">
            <p class="muted">No new requests. Make sure your vehicle is <strong>Available</strong> and its location is up to date.</p>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/partner/requests">Refresh</a>
        </div>
    </c:when>
    <c:otherwise>
        <c:forEach var="b" items="${requests}">
            <div class="card request">
                <div>
                    <h3>#${b.id} &middot; <c:out value="${b.productName}"/> (${b.weight} kg)</h3>
                    <p><strong>Pickup:</strong> <c:out value="${b.pickupAddress}"/><br>
                       <strong>Drop:</strong> <c:out value="${b.destinationAddress}"/></p>
                    <p class="muted">Customer: <c:out value="${b.customerName}"/> &middot; Vehicle <c:out value="${b.vehicleNumber}"/>
                        &middot; Match score ${b.matchScore}</p>
                </div>
                <div class="match-action">
                    <div class="price">&#8377;<fmt:formatNumber value="${b.estimatedCost}" pattern="#,##0"/></div>
                    <form method="post" action="${pageContext.request.contextPath}/partner/requests" class="button-row">
                        <input type="hidden" name="bookingId" value="${b.id}">
                        <button name="action" value="accept" class="btn btn-primary">Accept</button>
                        <button name="action" value="reject" class="btn btn-danger">Reject</button>
                    </form>
                </div>
            </div>
        </c:forEach>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
