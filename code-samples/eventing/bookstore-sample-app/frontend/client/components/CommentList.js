import CommentDisplay from './CommentDisplay';
const CommentList = () => {
	const comment = {
		avatar: '/images/knative-logo.png',
		time: '10:05',
		text: 'Good work!',
		emotion: 'Happy',
	};
	return <CommentDisplay comment={comment} />;
};

export default CommentList;
