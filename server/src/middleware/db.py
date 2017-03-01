class SQLAlchemySessionManager:
    """ 
    Create a scoped session for every request and close it when the request
    ends.
    """

    def __init__(self, Session):
        self.Session = Session

    def process_resource(self, req, resp, resource, params):
        req.session = self.Session()

    def process_response(self, req, resp, resource, req_succeeded):
        if hasattr(req, 'session'):
            if not req_succeeded:
                req.session.rollback()
                req.session.close()
            else:    
                req.session.commit()
                req.session.close()
