<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="My vehicles"/></jsp:include>

<h1>My vehicles</h1>

<c:forEach var="v" items="${vehicles}">
    <section class="card vehicle-manage">
        <div class="vehicle-head">
            <img class="vehicle-icon" src="${pageContext.request.contextPath}/assets/images/${v.vehicleType}.svg" alt="${v.vehicleType}">
            <div>
                <h2>${v.vehicleType} &middot; <c:out value="${v.vehicleNumber}"/></h2>
                <span class="badge vstatus-${v.status}">${v.status}</span>
                <small>${v.currentLoad} / ${v.totalCapacity} kg loaded &middot; <strong>${v.availableCapacity} kg free</strong></small>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/partner/vehicles" class="push-right">
                <input type="hidden" name="vehicleId" value="${v.id}">
                <c:choose>
                    <c:when test="${v.status == 'OFFLINE'}">
                        <button name="action" value="available" class="btn btn-primary">Go available</button>
                    </c:when>
                    <c:otherwise>
                        <button name="action" value="offline" class="btn btn-outline">Go offline</button>
                    </c:otherwise>
                </c:choose>
            </form>
        </div>

        <div class="grid-2">
            <form method="post" action="${pageContext.request.contextPath}/partner/vehicles" class="validate">
                <h3>Current location</h3>
                <input type="hidden" name="action" value="location">
                <input type="hidden" name="vehicleId" value="${v.id}">
                <div class="row">
                    <label>Latitude <input type="number" step="any" name="latitude" id="lat${v.id}" value="${v.currentLatitude}" required></label>
                    <label>Longitude <input type="number" step="any" name="longitude" id="lng${v.id}" value="${v.currentLongitude}" required></label>
                </div>
                <div class="button-row">
                    <button type="button" class="btn btn-outline" data-geolocate="lat${v.id},lng${v.id}">Use my current location</button>
                    <button type="submit" class="btn btn-primary">Save location</button>
                </div>
            </form>

            <form method="post" action="${pageContext.request.contextPath}/partner/vehicles">
                <h3>Where are you heading? <small class="muted">(optional, helps route matching)</small></h3>
                <input type="hidden" name="action" value="route">
                <input type="hidden" name="vehicleId" value="${v.id}">
                <label>Destination <input type="text" name="destination" id="dest${v.id}" value="<c:out value='${v.destination}'/>" placeholder="Leave empty if no fixed route"></label>
                <div class="row">
                    <label>Latitude <input type="number" step="any" name="destinationLatitude" id="dlat${v.id}" value="${v.destinationLatitude}"></label>
                    <label>Longitude <input type="number" step="any" name="destinationLongitude" id="dlng${v.id}" value="${v.destinationLongitude}"></label>
                </div>
                <div class="button-row">
                    <button type="button" class="btn btn-outline" data-lookup="dest${v.id},dlat${v.id},dlng${v.id}">Look up address</button>
                    <button type="submit" class="btn btn-primary">Save route</button>
                </div>
            </form>
        </div>
    </section>
</c:forEach>

<section class="card">
    <h2>Add a vehicle</h2>
    <form method="post" action="${pageContext.request.contextPath}/partner/vehicles" class="validate">
        <input type="hidden" name="action" value="add">
        <div class="row">
            <label>Vehicle type
                <select name="vehicleType" id="vehicleType" required>
                    <option value="BIKE" data-capacity="20">Bike</option>
                    <option value="AUTO" data-capacity="300">Auto</option>
                    <option value="TRUCK" data-capacity="2000">Truck</option>
                </select>
            </label>
            <label>Vehicle number
                <input type="text" name="vehicleNumber" placeholder="TN01AB1234" required>
            </label>
            <label>Total capacity (kg)
                <input type="number" name="totalCapacity" id="totalCapacity" min="1" step="0.1" value="20" required>
            </label>
        </div>
        <div class="row">
            <label>Latitude <input type="number" step="any" name="latitude" id="newLat"></label>
            <label>Longitude <input type="number" step="any" name="longitude" id="newLng"></label>
        </div>
        <div class="button-row">
            <button type="button" class="btn btn-outline" data-geolocate="newLat,newLng">Use my current location</button>
            <button type="submit" class="btn btn-primary">Add vehicle</button>
        </div>
    </form>
</section>

<script src="${pageContext.request.contextPath}/assets/js/geolocation.js"></script>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
