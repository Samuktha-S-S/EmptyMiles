<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Shared page top. Include with: <jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="..."/></jsp:include> --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><c:out value="${param.title}"/> | EmptyMiles</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/dashboard.css">
    <script>window.APP_CONTEXT = '${pageContext.request.contextPath}';</script>
</head>
<body>
<c:choose>
    <c:when test="${sessionScope.user.role == 'PARTNER'}">
        <jsp:include page="/WEB-INF/views/includes/partner-navbar.jsp"/>
    </c:when>
    <c:when test="${sessionScope.user.role == 'CUSTOMER'}">
        <jsp:include page="/WEB-INF/views/includes/customer-navbar.jsp"/>
    </c:when>
</c:choose>
<main class="container">
    <c:if test="${not empty sessionScope.flash}">
        <div class="alert alert-info"><c:out value="${sessionScope.flash}"/></div>
        <c:remove var="flash" scope="session"/>
    </c:if>
    <c:if test="${not empty requestScope.error}">
        <div class="alert alert-error"><c:out value="${requestScope.error}"/></div>
    </c:if>
