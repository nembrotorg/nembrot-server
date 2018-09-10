import React, { Component } from 'react';
import { graphql } from 'react-apollo';
import gql from 'graphql-tag';

class Text extends Component {

  componentWillReceiveProps(nextProps) {
    if (this.props.location.key !== nextProps.location.key) {
      this.props.noteQuery.refetch()
    }
  }

  render() {
    const query = this.props.noteQuery;
    if (query.loading) {
      return (
        <div>
          Loading...
        </div>
      )
    }
    if (query.error || query.allNotes.totalCount === 0) {
      return (
        <div>
          Error!
        </div>
      )
    }
    const note = query.allNotes.nodes[0];
    return (
      <div>
        <h1 dangerouslySetInnerHTML={{ __html: note.cachedHeadline }} />
        <section dangerouslySetInnerHTML={{ __html: note.cachedBodyHtml }} />
        {this.props.children}
      </div>
    )
  }
}

const NOTE_QUERY = gql`
  query NoteQuery($noteId: Int!) {
    allNotes(
      condition: {
        contentType: 0,
        hide: false,
        id: $noteId,
        isFeature: false
      }
    ) {
      nodes {
        cachedBodyHtml
        cachedHeadline
      }
      totalCount
    }
  }
`;

export default graphql(NOTE_QUERY, {
  name: 'noteQuery',
  options: ({ match }) => ({
    fetchPolicy: 'network-only',
    variables: {
      noteId: match.params.id,
    },
  }),
})(Text);
