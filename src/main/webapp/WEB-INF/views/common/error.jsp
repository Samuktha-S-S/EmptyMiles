<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Error"/></jsp:include>
<%-- requestScope.error is already shown by header.jsp; here we add a fallback for container errors (404, 500...). --%>
<div class="card center">
    <h2>Something went wrong</h2>
    <c:if test="${empty requestScope.error}">
        <c:choose>
            <c:when test="${requestScope['jakarta.servlet.error.status_code'] == 404}">
                <p>The page you asked for does not exist.</p>
            </c:when>
            <c:when test="${requestScope['jakarta.servlet.error.status_code'] == 403}">
                <p>This page is not available for your account type.</p>
            </c:when>
            <c:otherwise>
                <p>An unexpected error happened. Please try again.</p>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:choose>
        <c:when test="${sessionScope.user.role == 'PARTNER'}">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/partner/dashboard">Back to dashboard</a>
        </c:when>
        <c:when test="${sessionScope.user.role == 'CUSTOMER'}">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/customer/dashboard">Back to dashboard</a>
        </c:when>
        <c:otherwise>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/login">Go to login</a>
        </c:otherwise>
    </c:choose>
</div>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
