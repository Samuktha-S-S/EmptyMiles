<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar">
    <a class="brand" href="${pageContext.request.contextPath}/customer/dashboard">Empty<span>Miles</span></a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/customer/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/customer/shipment/new">Send goods</a>
        <span class="nav-user"><c:out value="${sessionScope.user.name}"/> (Customer)</span>
        <a class="btn btn-small btn-outline" href="${pageContext.request.contextPath}/logout">Logout</a>
    </div>
</nav>
