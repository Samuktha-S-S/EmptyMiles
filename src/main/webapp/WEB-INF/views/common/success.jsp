<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<jsp:include page="/WEB-INF/views/includes/header.jsp"><jsp:param name="title" value="Done"/></jsp:include>
<div class="card center">
    <div class="success-icon">&#10003;</div>
    <h2>Done!</h2>
    <p><c:out value="${message}"/></p>
    <a class="btn btn-primary" href="${pageContext.request.contextPath}${empty backUrl ? '/login' : backUrl}">Continue</a>
</div>
<jsp:include page="/WEB-INF/views/includes/footer.jsp"/>
