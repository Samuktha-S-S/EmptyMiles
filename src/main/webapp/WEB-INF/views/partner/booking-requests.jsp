<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="Booking Requests"/>
    <jsp:param name="nav" value="requests"/>
</jsp:include>

<div class="page-head">
    <div>
        <h1>Booking Requests</h1>
        <p>Customers chose your vehicle for these shipments. Accepting reserves the space on your vehicle.</p>
    </div>
    <div class="actions">
        <a class="btn btn-outline" data-loading href="${ctx}/partner/requests"><svg class="i"><use href="${ico}#refresh"/></svg><span>Refresh</span></a>
    </div>
</div>

<c:choose>
    <c:when test="${empty requests}">
        <section class="card">
            <div class="empty">
                <div class="empty-icon"><svg class="i"><use href="${ico}#inbox"/></svg></div>
                <h3>No new requests</h3>
                <p>Make sure your vehicle is <strong>Available</strong> and its location is up to date so customers' shipments can match it.</p>
                <div class="button-row" style="justify-content:center;margin-top:10px">
                    <a class="btn btn-outline" href="${ctx}/partner/location"><svg class="i"><use href="${ico}#crosshair"/></svg><span>Update location</span></a>
                    <a class="btn btn-primary" href="${ctx}/partner/matching-shipments"><svg class="i"><use href="${ico}#search"/></svg><span>See matching shipments</span></a>
                </div>
            </div>
        </section>
    </c:when>
    <c:otherwise>
        <c:forEach var="b" items="${requests}">
            <c:set var="m" value="${matchByBooking[b.id]}"/>
            <article class="card request-card">
                <div class="request-main">
                    <div class="row-flex">
                        <span class="vtype-icon" style="width:44px;height:44px"><svg class="i" style="width:24px;height:24px"><use href="${ico}#package"/></svg></span>
                        <div>
                            <h3 style="font-size:17px"><c:out value="${b.productName}"/></h3>
                            <div class="small subtle">Booking #${b.id} &middot; for <span class="reg-plate"><c:out value="${b.vehicleNumber}"/></span></div>
                        </div>
                        <span class="badge tone-pending push-right">New request</span>
                    </div>
                    <div class="route" style="margin-top:16px">
                        <div class="route-stop"><span class="route-dot"></span><div><div class="k">Pickup</div><div class="v"><c:out value="${b.pickupAddress}"/></div></div></div>
                        <div class="route-stop to"><span class="route-dot"></span><div><div class="k">Destination</div><div class="v"><c:out value="${b.destinationAddress}"/></div></div></div>
                    </div>
                    <div class="request-meta">
                        <div><div class="k">Customer</div><div class="v"><c:out value="${b.customerName}"/></div></div>
                        <div><div class="k">Weight</div><div class="v"><fmt:formatNumber value="${b.weight}" maxFractionDigits="2"/> kg</div></div>
                        <div><div class="k">Distance to pickup</div><div class="v">
                            <c:choose><c:when test="${not empty m}"><fmt:formatNumber value="${m.distanceToPickupKm}" maxFractionDigits="1"/> km</c:when><c:otherwise>&ndash;</c:otherwise></c:choose></div></div>
                        <div><div class="k">Route</div>
                            <c:choose>
                                <c:when test="${empty m}"><div class="v warn">Check vehicle</div></c:when>
                                <c:when test="${m.onRoute}"><div class="v ok">Compatible &#10003;</div><div class="small subtle"><fmt:formatNumber value="${m.detourKm}" maxFractionDigits="1"/> km detour</div></c:when>
                                <c:otherwise><div class="v ok">Compatible &#10003;</div><div class="small subtle">No fixed route set</div></c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                    <c:if test="${empty m}">
                        <p class="small" style="color:var(--amber-700);margin-top:12px">Your vehicle doesn't fit this shipment right now (it may be offline, full or too far). You can still accept if you have the space.</p>
                    </c:if>
                </div>
                <aside class="request-side">
                    <div>
                        <div class="small subtle">Fare</div>
                        <div class="fare">&#8377;<fmt:formatNumber value="${b.estimatedCost}" pattern="#,##0"/></div>
                    </div>
                    <div class="small subtle"><svg class="i i-sm"><use href="${ico}#clock"/></svg> Requested ${b.createdAt.format(dtf)}</div>
                    <div class="small subtle"><svg class="i i-sm"><use href="${ico}#star"/></svg> Match score <fmt:formatNumber value="${b.matchScore}" minFractionDigits="1" maxFractionDigits="1"/> / 100</div>
                    <form method="post" action="${ctx}/partner/requests" class="stack-sm" style="margin-top:auto">
                        <input type="hidden" name="bookingId" value="${b.id}">
                        <button name="action" value="accept" class="btn btn-primary btn-block"><svg class="i"><use href="${ico}#check"/></svg><span>Accept</span></button>
                        <button name="action" value="reject" class="btn btn-danger btn-block"
                                data-confirm="Reject this request?" data-confirm-text="The customer will be asked to choose another vehicle." data-confirm-ok="Reject" data-confirm-tone="danger">
                            <span>Reject</span></button>
                    </form>
                </aside>
            </article>
        </c:forEach>
    </c:otherwise>
</c:choose>

<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
