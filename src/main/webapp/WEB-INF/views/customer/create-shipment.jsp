<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Send goods"/></jsp:include>

<h1>Send goods</h1>
<p class="muted">Enter where to pick up and where to deliver. Use your current location or look up an address
    (free OpenStreetMap search), or type the latitude/longitude yourself.</p>

<form method="post" action="${pageContext.request.contextPath}/customer/shipment/new" class="card validate">
    <h2>1. Pickup</h2>
    <label>Pickup address
        <input type="text" name="pickupAddress" id="pickupAddress" value="<c:out value='${param.pickupAddress}'/>" required>
    </label>
    <div class="row">
        <label>Latitude <input type="number" step="any" name="pickupLatitude" id="pickupLatitude" value="<c:out value='${param.pickupLatitude}'/>" required></label>
        <label>Longitude <input type="number" step="any" name="pickupLongitude" id="pickupLongitude" value="<c:out value='${param.pickupLongitude}'/>" required></label>
    </div>
    <div class="button-row">
        <button type="button" class="btn btn-outline" data-geolocate="pickupLatitude,pickupLongitude">Use my current location</button>
        <button type="button" class="btn btn-outline" data-lookup="pickupAddress,pickupLatitude,pickupLongitude">Look up address</button>
    </div>

    <h2>2. Destination</h2>
    <label>Destination address
        <input type="text" name="destinationAddress" id="destinationAddress" value="<c:out value='${param.destinationAddress}'/>" required>
    </label>
    <div class="row">
        <label>Latitude <input type="number" step="any" name="destinationLatitude" id="destinationLatitude" value="<c:out value='${param.destinationLatitude}'/>" required></label>
        <label>Longitude <input type="number" step="any" name="destinationLongitude" id="destinationLongitude" value="<c:out value='${param.destinationLongitude}'/>" required></label>
    </div>
    <div class="button-row">
        <button type="button" class="btn btn-outline" data-lookup="destinationAddress,destinationLatitude,destinationLongitude">Look up address</button>
    </div>

    <h2>3. Product</h2>
    <div class="row">
        <label>Product name
            <input type="text" name="productName" value="<c:out value='${param.productName}'/>" placeholder="e.g. Clothes" required>
        </label>
        <label>Product type
            <select name="productType" required>
                <c:forEach var="t" items="${['Clothes','Documents','Electronics','Food','Groceries','Furniture','Medicines','Other']}">
                    <option ${param.productType == t ? 'selected' : ''}>${t}</option>
                </c:forEach>
            </select>
        </label>
    </div>
    <div class="row">
        <label>Quantity (items)
            <input type="number" name="quantity" min="1" step="1" value="${empty param.quantity ? 1 : param.quantity}" required>
        </label>
        <label>Total weight (kg)
            <input type="number" name="weight" min="0.1" step="0.1" value="<c:out value='${param.weight}'/>" required>
        </label>
    </div>

    <button type="submit" class="btn btn-primary btn-block">Search suitable vehicles</button>
</form>

<script src="${pageContext.request.contextPath}/assets/js/geolocation.js"></script>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
