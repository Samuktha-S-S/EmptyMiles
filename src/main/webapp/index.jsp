<%-- Entry point: send visitors to the login page (which forwards logged-in users to their dashboard). --%>
<% response.sendRedirect(request.getContextPath() + "/login"); %>
