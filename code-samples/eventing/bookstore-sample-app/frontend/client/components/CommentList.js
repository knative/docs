import CommentDisplay from './CommentDisplay';
const CommentList = () => {
	const comment = {
		avatar: '/images/avatar.jpg',
		time: '10:05',
		text: 'I used this provider to insert a different theme object depending on a person ',
		emotion: '😃',
		label: 'grinning face',
	};
	return <CommentDisplay comment={comment} />;
};

export default CommentList;
