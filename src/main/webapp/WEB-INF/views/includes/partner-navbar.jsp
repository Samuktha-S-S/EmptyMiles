<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar">
    <a class="brand" href="${pageContext.request.contextPath}/partner/dashboard">Empty<span>Miles</span></a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/partner/dashboard">Dashboard</a>
        <a href="${pageContext.request.contextPath}/partner/vehicles">My vehicles</a>
        <a href="${pageContext.request.contextPath}/partner/requests">Requests</a>
        <a href="${pageContext.request.contextPath}/partner/delivery">Active deliveries</a>
        <span class="nav-user"><c:out value="${sessionScope.user.name}"/> (Partner)</span>
        <a class="btn btn-small btn-outline" href="${pageContext.request.contextPath}/logout">Logout</a>
    </div>
</nav>
