<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp">
    <jsp:param name="title" value="My Vehicle"/>
    <jsp:param name="nav" value="vehicles"/>
</jsp:include>

<div class="page-head">
    <div>
        <h1>${fn:length(vehicles) > 1 ? 'My Vehicles' : 'My Vehicle'}</h1>
        <p>Go available to receive bookings. Customers only see vehicles that are available and have shared a location.</p>
    </div>
    <div class="actions">
        <a class="btn btn-outline" href="${ctx}/partner/location"><svg class="i"><use href="${ico}#crosshair"/></svg><span>Location &amp; route</span></a>
    </div>
</div>

<c:forEach var="v" items="${vehicles}">
    <section class="card" style="margin-bottom:20px">
        <%@ include file="vehicle-overview.jspf" %>
        <div class="card-foot" style="margin:20px -20px -20px;flex-wrap:wrap">
            <span class="small muted">
                <c:choose>
                    <c:when test="${v.status == 'AVAILABLE'}">You're visible to customers for shipments up to <fmt:formatNumber value="${v.availableCapacity}" maxFractionDigits="2"/> kg.</c:when>
                    <c:when test="${v.status == 'BUSY'}">This vehicle is full. It becomes available again when a delivery is completed.</c:when>
                    <c:otherwise>You're offline. Customers can't book this vehicle.</c:otherwise>
                </c:choose>
            </span>
            <form method="post" action="${ctx}/partner/vehicles" class="push-right">
                <input type="hidden" name="vehicleId" value="${v.id}">
                <c:choose>
                    <c:when test="${v.status == 'OFFLINE'}">
                        <button name="action" value="available" class="btn btn-primary"><svg class="i"><use href="${ico}#power"/></svg><span>Go available</span></button>
                    </c:when>
                    <c:otherwise>
                        <button name="action" value="offline" class="btn btn-outline"
                                data-confirm="Go offline?" data-confirm-text="Customers won't be able to book ${v.vehicleNumber} until you go available again." data-confirm-ok="Go offline">
                            <svg class="i"><use href="${ico}#power"/></svg><span>Go offline</span></button>
                    </c:otherwise>
                </c:choose>
            </form>
        </div>
    </section>
</c:forEach>

<section class="card" id="add">
    <div class="card-head"><h2>Add a vehicle</h2><span class="sub">New vehicles start offline</span></div>
    <form method="post" action="${ctx}/partner/vehicles" class="validate" novalidate>
        <input type="hidden" name="action" value="add">
        <div class="form-row-3">
            <label class="field"><span>Vehicle type</span>
                <select name="vehicleType" id="vehicleType" required>
                    <option value="BIKE" data-capacity="20">Bike</option>
                    <option value="AUTO" data-capacity="300">Auto</option>
                    <option value="TRUCK" data-capacity="2000">Truck</option>
                </select>
            </label>
            <label class="field"><span>Registration number</span>
                <input type="text" name="vehicleNumber" placeholder="TN01AB1234" style="text-transform:uppercase" required>
            </label>
            <label class="field"><span>Total capacity</span>
                <span class="input-group"><input type="number" name="totalCapacity" id="totalCapacity" min="1" step="0.1" value="20" required><span class="unit">kg</span></span>
            </label>
        </div>
        <div class="form-row">
            <label class="field"><span>Latitude <span class="optional">(optional)</span></span><input type="number" step="any" min="-90" max="90" name="latitude" id="newLat"></label>
            <label class="field"><span>Longitude <span class="optional">(optional)</span></span><input type="number" step="any" min="-180" max="180" name="longitude" id="newLng"></label>
        </div>
        <div class="button-row">
            <button type="button" class="btn btn-outline" data-geolocate="newLat,newLng"><svg class="i"><use href="${ico}#crosshair"/></svg><span>Use my current location</span></button>
            <button type="submit" class="btn btn-primary push-right"><svg class="i"><use href="${ico}#plus"/></svg><span>Add vehicle</span></button>
        </div>
    </form>
</section>

<script src="${ctx}/assets/js/geolocation.js"></script>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
